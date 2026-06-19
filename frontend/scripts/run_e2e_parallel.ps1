#!/usr/bin/env pwsh
param(
    [string[]]$Devices,
    [int]$MaxConcurrency = 0,
    [string]$DartDefineFile = ".env.e2e"
)

$ErrorActionPreference = "Stop"

$testFiles = @(
    "integration_test/tests/auth_test.dart",
    "integration_test/tests/feed_test.dart",
    "integration_test/tests/chat_test.dart",
    "integration_test/tests/friends_test.dart",
    "integration_test/tests/notifications_test.dart",
    "integration_test/tests/profile_test.dart"
)

# Auto-detect devices
if (-not $Devices) {
    try {
        $raw = flutter devices --machine 2>$null | ConvertFrom-Json
        $Devices = @($raw | Where-Object {
            $_.targetPlatform -match "android|ios"
        } | ForEach-Object { $_.id })
    } catch {
        Write-Error "No devices detected. Check Flutter SDK."
        exit 1
    }
}

if ($Devices.Count -eq 0) {
    Write-Error "No device/emulator found. Start one first."
    exit 1
}

$effectiveConcurrency = $Devices.Count
if ($MaxConcurrency -gt 0 -and $MaxConcurrency -lt $effectiveConcurrency) {
    $effectiveConcurrency = $MaxConcurrency
}

Write-Host ""
Write-Host "=== E2E Parallel Runner ===" -ForegroundColor Cyan
Write-Host "Devices:     $($Devices -join ', ')"
Write-Host "Test files:  $($testFiles.Count)"
Write-Host "Concurrency: $effectiveConcurrency"
Write-Host ""

$pendingFiles = [System.Collections.Queue]::new($testFiles)
$activeJobs = @{}
$results = @()
$deviceIndex = 0
$startTime = Get-Date

while ($pendingFiles.Count -gt 0 -or $activeJobs.Count -gt 0) {
    while ($pendingFiles.Count -gt 0 -and $activeJobs.Count -lt $effectiveConcurrency) {
        $testFile = $pendingFiles.Dequeue()
        $device = $Devices[$deviceIndex % $Devices.Count]
        $deviceIndex++

        Write-Host "[START] $testFile -> $device" -ForegroundColor Yellow

        $job = Start-Job -ScriptBlock {
            param($d, $t, $f, $w)
            Set-Location $w
            $out = flutter test $t --device-id $d --dart-define-from-file=$f 2>&1
            @{ Output = ($out -join "`n"); ExitCode = $LASTEXITCODE }
        } -ArgumentList $device, $testFile, $DartDefineFile, (Get-Location).Path

        $activeJobs[$job.Id] = @{
            Job = $job
            File = $testFile
            Device = $device
            StartTime = Get-Date
        }
    }

    if ($activeJobs.Count -gt 0) {
        $allJobs = $activeJobs.Values | ForEach-Object { $_.Job }
        $completedJob = $allJobs | Wait-Job -Any

        $entry = $activeJobs[$completedJob.Id]
        $jobResult = Receive-Job -Job $completedJob
        $duration = (Get-Date) - $entry.StartTime
        $passed = ($completedJob.State -eq 'Completed' -and $jobResult.ExitCode -eq 0)

        if ($passed) { $status = "PASS"; $color = "Green" }
        else         { $status = "FAIL"; $color = "Red" }

        $mins = [int][math]::Floor($duration.TotalMinutes)
        $secs = $duration.Seconds
        $durationStr = "{0}m{1:D2}s" -f $mins, $secs
        Write-Host "[$status] $($entry.File)  ($($entry.Device))  [$durationStr]" -ForegroundColor $color

        $results += @{
            File = $entry.File
            Device = $entry.Device
            Passed = $passed
            Output = $jobResult.Output
            Duration = $duration
        }

        Remove-Job -Job $completedJob
        $activeJobs.Remove($completedJob.Id)
    }
}

$totalDuration = (Get-Date) - $startTime

# Results summary
Write-Host ""
Write-Host "=== RESULTS ===" -ForegroundColor Cyan
$passedCount = @($results | Where-Object { $_.Passed }).Count
$failedCount = @($results | Where-Object { -not $_.Passed }).Count

foreach ($r in $results) {
    if ($r.Passed) { $icon = "[PASS]" } else { $icon = "[FAIL]" }
    $mins = [int][math]::Floor($r.Duration.TotalMinutes)
    $secs = $r.Duration.Seconds
    $dStr = "{0}m{1:D2}s" -f $mins, $secs
    if ($r.Passed) { $c = "Green" } else { $c = "Red" }
    Write-Host "$icon $($r.File)  ($($r.Device))  [$dStr]" -ForegroundColor $c
}

$failedResults = @($results | Where-Object { -not $_.Passed })
if ($failedResults.Count -gt 0) {
    Write-Host ""
    Write-Host "=== FAILED TEST OUTPUT ===" -ForegroundColor Red
    foreach ($r in $failedResults) {
        Write-Host "--- $($r.File) ---" -ForegroundColor Red
        Write-Host $r.Output
    }
}

$tMins = [int][math]::Floor($totalDuration.TotalMinutes)
$tSecs = $totalDuration.Seconds
$totalStr = "{0}m{1:D2}s" -f $tMins, $tSecs

if ($failedCount -gt 0) { $rc = "Red" } else { $rc = "Green" }
Write-Host ""
Write-Host "Total: $passedCount passed, $failedCount failed  (wall time: $totalStr)" -ForegroundColor $rc

if ($failedCount -gt 0) { exit 1 }
