# KoroKoroRecomp - one-click build and launch (called by run.bat).
#
# 1. Finds your disc image in data\ (.chd, or .cue + .bin).
# 2. Downloads a pinned, SHA-256-verified portable toolchain (LLVM-MinGW,
#    CMake, Ninja, Python). Visual Studio is NOT required.
# 3. Downloads the pinned, SHA-256-verified psxrecomp framework sources.
# 4. Verifies the disc, recompiles the game into C, compiles the native exe.
# 5. Copies the result to out\ and starts the game.
#
# Later runs skip straight to step 5 while the build is up to date.
#   run.bat -Rebuild     force a full rebuild
#   run.bat -NoLaunch    build only
#
# This file is ASCII-only on purpose: Windows PowerShell 5.1 misreads
# UTF-8 scripts without a BOM.

[CmdletBinding()]
param(
    [switch]$Rebuild,
    [switch]$NoLaunch
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Root     = Split-Path -Parent $PSScriptRoot
$DataDir  = Join-Path $Root "data"
$OutDir   = Join-Path $Root "out"
$Cache    = Join-Path $PSScriptRoot ".cache"
$Tree     = Join-Path $PSScriptRoot ".build\tree"
$Pins     = Get-Content (Join-Path $PSScriptRoot "pins.json") -Raw | ConvertFrom-Json
$Version  = (Get-Content (Join-Path $Root "version.txt") -Raw).Trim()
$ExeName  = $Pins.game.exe_name
$Steps    = 7

function Write-Step([int]$n, [string]$msg) {
    Write-Host ""
    Write-Host ("[{0}/{1}] {2}" -f $n, $Steps, $msg) -ForegroundColor Cyan
}

function Fail([string]$msg) {
    Write-Host ""
    Write-Host "ERROR: $msg" -ForegroundColor Red
    Write-Host ""
    exit 1
}

function Invoke-Native([string]$what, [scriptblock]$cmd) {
    & $cmd
    if ($LASTEXITCODE -ne 0) { Fail "$what failed (exit code $LASTEXITCODE)." }
}

function Get-Sha256([string]$path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
}

function Get-Verified([string]$url, [string]$dest, [string]$sha256) {
    if ((Test-Path -LiteralPath $dest) -and ((Get-Sha256 $dest) -eq $sha256)) { return }
    $tmp = "$dest.part"
    Write-Host "  downloading $url"
    $curl = Join-Path $env:SystemRoot "System32\curl.exe"
    if (Test-Path $curl) {
        & $curl -fL --retry 3 -o $tmp $url
        if ($LASTEXITCODE -ne 0) { Fail "download failed: $url" }
    } else {
        Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
    }
    $got = Get-Sha256 $tmp
    if ($got -ne $sha256) {
        Remove-Item -LiteralPath $tmp -Force
        Fail "checksum mismatch for $url`n  expected $sha256`n  got      $got"
    }
    Move-Item -LiteralPath $tmp -Destination $dest -Force
}

function Expand-Zip([string]$zip, [string]$dest) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    $tar = Join-Path $env:SystemRoot "System32\tar.exe"
    if (Test-Path $tar) {
        & $tar -xf $zip -C $dest
        if ($LASTEXITCODE -ne 0) { Fail "could not extract $zip" }
    } else {
        Expand-Archive -LiteralPath $zip -DestinationPath $dest -Force
    }
}

function Copy-Tree([string]$from, [string]$to) {
    New-Item -ItemType Directory -Force -Path $to | Out-Null
    & robocopy $from $to /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
    if ($LASTEXITCODE -ge 8) { Fail "copy failed: $from -> $to" }
    $global:LASTEXITCODE = 0
}

Write-Host "KoroKoroRecomp $Version - static recompilation of KoroKoro Post nin (SLPS-03479)" -ForegroundColor White

# ---------------------------------------------------------------- 1. disc
Write-Step 1 "Looking for your disc image in data\"
if ([Environment]::Is64BitOperatingSystem -eq $false) { Fail "64-bit Windows is required." }
$discs = @(Get-ChildItem -LiteralPath $DataDir -File | Where-Object { $_.Extension -in ".chd", ".cue" })
if ($discs.Count -eq 0) {
    Fail ("no disc image found in data\.`n" +
          "  Put your own dump of KoroKoro Post nin (Japan) (SLPS-03479) there,`n" +
          "  either as a .chd file or as a .cue with its .bin.")
}
if ($discs.Count -gt 1) {
    Fail ("more than one disc image in data\: " + (($discs | ForEach-Object { $_.Name }) -join ", ") +
          "`n  Leave only one .chd or one .cue/.bin pair.")
}
$Disc = $discs[0].FullName
Write-Host "  using $($discs[0].Name)"
if ($discs[0].Extension -eq ".cue") {
    $cueText = Get-Content -LiteralPath $Disc -Raw
    foreach ($m in [regex]::Matches($cueText, 'FILE\s+"([^"]+)"')) {
        if (-not (Test-Path -LiteralPath (Join-Path $DataDir $m.Groups[1].Value))) {
            Fail "the .cue references '$($m.Groups[1].Value)', which is not in data\."
        }
    }
}
$discItem = Get-Item -LiteralPath $Disc
$DiscKey = "{0}|{1}|{2}" -f $discItem.Name, $discItem.Length, $discItem.LastWriteTimeUtc.Ticks
$StampFile = Join-Path $OutDir ".build-stamp"
$Stamp = "$Version|$DiscKey"

if (-not $Rebuild -and (Test-Path (Join-Path $OutDir "$ExeName.exe")) -and
    (Test-Path $StampFile) -and ((Get-Content $StampFile -Raw).Trim() -eq $Stamp)) {
    Write-Host "  build is up to date (run.bat -Rebuild forces a rebuild)"
} else {
    # ---------------------------------------------------------- 2. toolchain
    Write-Step 2 "Portable toolchain ($($Pins.toolchain.name))"
    New-Item -ItemType Directory -Force -Path $Cache | Out-Null
    $tcZip = Join-Path $Cache "cmake-clang-v1-windows-x64.zip"
    $Tc = Join-Path $Cache "toolchain"
    $tcStamp = Join-Path $Tc ".sha256"
    if (-not ((Test-Path $tcStamp) -and ((Get-Content $tcStamp -Raw).Trim() -eq $Pins.toolchain.sha256))) {
        Get-Verified $Pins.toolchain.url $tcZip $Pins.toolchain.sha256
        if (Test-Path $Tc) { Remove-Item -Recurse -Force $Tc }
        Write-Host "  extracting toolchain (about 1 GB, takes a minute)"
        Expand-Zip $tcZip $Tc
        Set-Content -Path $tcStamp -Value $Pins.toolchain.sha256 -Encoding ascii
        Remove-Item -LiteralPath $tcZip -Force
    } else {
        Write-Host "  already installed"
    }
    foreach ($exe in "bin\clang.exe", "bin\cmake.exe", "bin\ninja.exe", "python\python.exe") {
        if (-not (Test-Path (Join-Path $Tc $exe))) { Fail "toolchain is incomplete ($exe missing); run.bat -Rebuild" }
    }
    # Same environment the pack's own env.bat sets up.
    $env:PATH = "$Tc\bin;$Tc\python;$env:PATH"
    $env:CC = "$Tc\bin\clang.exe"
    $env:CXX = "$Tc\bin\clang++.exe"
    $env:AR = "$Tc\bin\llvm-ar.exe"
    $env:RANLIB = "$Tc\bin\llvm-ranlib.exe"
    $env:RETCOMM_TOOLCHAIN_DIR = $Tc
    $env:PSXRECOMP_TOOLCHAIN_DIR = $Tc
    $env:PYTHONNOUSERSITE = "1"
    Remove-Item Env:PYTHONHOME, Env:PYTHONPATH -ErrorAction SilentlyContinue
    if (Test-Path "$Tc\deps\include\zlib.h") { $env:ZLIB_ROOT = "$Tc\deps" }
    if (Test-Path "$Tc\deps\lib\cmake\SDL3") { $env:SDL3_DIR = "$Tc\deps\lib\cmake\SDL3" }
    $Py = "$Tc\python\python.exe"
    $CMake = "$Tc\bin\cmake.exe"

    # ------------------------------------------------------------ 3. sources
    Write-Step 3 "Framework sources (psxrecomp and friends, pinned commits)"
    New-Item -ItemType Directory -Force -Path $Tree | Out-Null
    foreach ($s in $Pins.sources) {
        $dest = Join-Path $Tree $s.dest
        $pinFile = Join-Path $dest ".korokoro-pin"
        if ((Test-Path $pinFile) -and ((Get-Content $pinFile -Raw).Trim() -eq $s.commit)) {
            Write-Host "  $($s.name) ok"
            continue
        }
        $zip = Join-Path $Cache "$($s.name)-$($s.commit).zip"
        Get-Verified "https://codeload.github.com/$($s.repo)/zip/$($s.commit)" $zip $s.sha256
        $tmp = Join-Path $Cache "x-$($s.name)"
        if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
        Expand-Zip $zip $tmp
        $top = @(Get-ChildItem -LiteralPath $tmp -Directory)[0].FullName
        Copy-Tree $top $dest
        Remove-Item -Recurse -Force $tmp
        Set-Content -Path $pinFile -Value $s.commit -Encoding ascii
        Write-Host "  $($s.name) $($s.commit.Substring(0, 8)) installed"
    }
    # This project's own files (game.toml, seeds, CMakeLists, ...).
    Copy-Tree (Join-Path $Root "project") $Tree
    $gameToml = Join-Path $Tree "game.toml"
    $discFwd = $Disc.Replace("\", "/")
    (Get-Content -LiteralPath $gameToml -Raw).Replace("@DISC@", $discFwd) |
        Set-Content -LiteralPath $gameToml -Encoding ascii -NoNewline

    # ----------------------------------------------------------- 4. emitters
    Write-Step 4 "Building the recompiler"
    $recBuild = Join-Path $Tree "build-recompiler"
    Invoke-Native "configuring the recompiler" {
        & $CMake -S "$Tree\psxrecomp\recompiler" -B $recBuild -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF
    }
    Invoke-Native "building the recompiler" {
        & $CMake --build $recBuild --target psxrecomp-game psxrecomp-bios chdr
    }

    # ----------------------------------------------------------- 5. generate
    Write-Step 5 "Verifying the disc and recompiling the game into C"
    & $Py "$Tree\psxrecomp\psxrecomp_cli.py" generate --config $gameToml --project-root $Tree `
        --disc $Disc --no-toolchain-download
    if ($LASTEXITCODE -eq 3) {
        Fail ("your disc image does not match the supported dump of KoroKoro Post nin (Japan).`n" +
              "  Expected data track: $($Pins.game.data_track_size) bytes, MD5 $($Pins.game.data_track_md5).")
    }
    if ($LASTEXITCODE -ne 0) { Fail "recompilation failed (exit code $LASTEXITCODE)." }

    # -------------------------------------------------------------- 6. build
    Write-Step 6 "Compiling the native game (this is the long step)"
    $relBuild = Join-Path $Tree "build-release"
    Invoke-Native "configuring the game" {
        & $CMake -S $Tree -B $relBuild -G Ninja -DCMAKE_BUILD_TYPE=Release
    }
    Invoke-Native "compiling the game" {
        & $CMake --build $relBuild --target psx-runtime
    }

    # -------------------------------------------------------------- 7. stage
    Write-Step 7 "Installing into out\"
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $relBuild "$ExeName.exe") -Destination $OutDir -Force
    foreach ($d in "bios", "assets", "mods") {
        $src = Join-Path $relBuild $d
        if (Test-Path $src) { Copy-Tree $src (Join-Path $OutDir $d) }
    }
    foreach ($f in "game.toml", "game_options.toml") {
        $src = Join-Path $relBuild $f
        if (Test-Path $src) { Copy-Item -LiteralPath $src -Destination $OutDir -Force }
    }
    Set-Content -Path $StampFile -Value $Stamp -Encoding ascii
    Write-Host "  done: $OutDir\$ExeName.exe" -ForegroundColor Green
}

if ($NoLaunch) { exit 0 }
Write-Host ""
Write-Host "Starting the game..." -ForegroundColor Green
Start-Process -FilePath (Join-Path $OutDir "$ExeName.exe") -WorkingDirectory $OutDir `
    -ArgumentList @("--disc", "`"$Disc`"")
exit 0
