[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Workspace,
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug",
    [string]$ProgrammerPath,
    [switch]$SkipBuild,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Invoke-ExternalTool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    Write-Host ("> " + $FilePath + " " + ($Arguments -join " "))
    if ($DryRun) {
        return
    }

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $FilePath"
    }
}

function Find-ProgrammerCli {
    param([string]$RequestedPath)

    $candidates = @()
    if ($RequestedPath) {
        $candidates += $RequestedPath
    }
    if ($env:STM32_PROGRAMMER_CLI) {
        $candidates += $env:STM32_PROGRAMMER_CLI
    }

    $command = Get-Command STM32_Programmer_CLI.exe -ErrorAction SilentlyContinue
    if ($command) {
        $candidates += $command.Source
    }

    $candidates += @(
        "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe",
        "C:\Program Files (x86)\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
    )

    $bundleRoot = Join-Path $env:LOCALAPPDATA "stm32cube\bundles\programmer"
    if (Test-Path -LiteralPath $bundleRoot) {
        $candidates += @(Get-ChildItem -LiteralPath $bundleRoot -Filter STM32_Programmer_CLI.exe -Recurse -File -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty FullName)
    }

    foreach ($candidate in $candidates) {
        if (-not [string]::IsNullOrWhiteSpace($candidate) -and (Test-Path -LiteralPath $candidate)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw "STM32_Programmer_CLI.exe was not found. Install STM32CubeProgrammer or set STM32_PROGRAMMER_CLI."
}

try {
    $workspacePath = (Resolve-Path -LiteralPath $Workspace).Path
}
catch {
    throw "Workspace does not exist: $Workspace"
}

Push-Location $workspacePath
try {
    $presetPath = Join-Path $workspacePath "CMakePresets.json"
    $buildDir = Join-Path $workspacePath "build\Download-$Configuration"
    $firmwarePath = Join-Path $buildDir "stm32.hex"

    if (-not (Test-Path -LiteralPath $presetPath)) {
        throw "CMakePresets.json was not found in $workspacePath."
    }

    if (-not $SkipBuild) {
        $cmake = Get-Command cmake -ErrorAction SilentlyContinue
        if (-not $cmake) {
            throw "cmake.exe was not found in PATH."
        }

        # Configure explicitly from this workspace so stale CMake presets cannot redirect the build.
        Invoke-ExternalTool -FilePath $cmake.Source -Arguments @(
            "-S", $workspacePath,
            "-B", $buildDir,
            "-G", "Ninja",
            "-DCMAKE_BUILD_TYPE=$Configuration"
        )
        Invoke-ExternalTool -FilePath $cmake.Source -Arguments @("--build", $buildDir)
    }

    if (-not (Test-Path -LiteralPath $firmwarePath)) {
        throw "Expected firmware was not generated: $firmwarePath"
    }

    $firmware = Get-Item -LiteralPath $firmwarePath
    if ($firmware.Length -le 0) {
        throw "Generated firmware is empty: $firmwarePath"
    }

    $cliPath = Find-ProgrammerCli -RequestedPath $ProgrammerPath
    Write-Host ("Firmware: " + $firmware.FullName)
    Write-Host ("Programmer: " + $cliPath)

    Invoke-ExternalTool -FilePath $cliPath -Arguments @(
        "-c", "port=SWD", "freq=1000",
        "-w", $firmware.FullName,
        "-v", "-rst"
    )
    Write-Host "STM32 programming completed."
}
finally {
    Pop-Location
}
