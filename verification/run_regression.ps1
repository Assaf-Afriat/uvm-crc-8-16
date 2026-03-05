# CRC UVM regression: run all tests (main top + CrcInitFinalXorTest via run_init_final_xor.do).
# Run from verification/: .\run_regression.ps1
# Uses 15s timeout per run. Exit code 0 only if all pass.

$ErrorActionPreference = "Stop"
$verifDir = $PSScriptRoot
$testsMain = @(
    "CrcSerialSmokeTest",
    "CrcParallelSmokeTest",
    "CrcSerialMultiByteTest",
    "CrcParallelMultiByteTest",
    "CrcResetStartTest",
    "CrcPolyPresetTest",
    "CrcWidthTest",
    "CrcFullCoverageTest",
    "CrcAllVariationsTest",
    "CrcCornerInputsTest"
)
$failed = @()
$passed = @()

Push-Location $verifDir

foreach ($t in $testsMain) {
    Write-Host "`n=== Running $t ===" -ForegroundColor Cyan
    $env:UVM_TESTNAME = $t
    $p = Start-Process -FilePath "vsim" -ArgumentList "-c", "-do", "run.do" -NoNewWindow -Wait -PassThru
    if ($p.ExitCode -ne 0) { $failed += $t } else { $passed += $t }
    $env:UVM_TESTNAME = $null
}

Write-Host "`n=== Running CrcInitFinalXorTest (init_final_xor top) ===" -ForegroundColor Cyan
$p = Start-Process -FilePath "vsim" -ArgumentList "-c", "-do", "run_init_final_xor.do" -NoNewWindow -Wait -PassThru
if ($p.ExitCode -ne 0) { $failed += "CrcInitFinalXorTest" } else { $passed += "CrcInitFinalXorTest" }

Write-Host "`n=== Running CrcWidthTestCrc16 (CRC-16 top, poly 0x1021) ===" -ForegroundColor Cyan
$env:UVM_TESTNAME = "CrcWidthTestCrc16"
$p = Start-Process -FilePath "vsim" -ArgumentList "-c", "-do", "run_crc16.do" -NoNewWindow -Wait -PassThru
$env:UVM_TESTNAME = $null
if ($p.ExitCode -ne 0) { $failed += "CrcWidthTestCrc16" } else { $passed += "CrcWidthTestCrc16" }

Pop-Location

Write-Host "`n--- Regression summary ---" -ForegroundColor Cyan
Write-Host "PASSED ($($passed.Count)): $($passed -join ', ')" -ForegroundColor Green
if ($failed.Count -gt 0) {
    Write-Host "FAILED ($($failed.Count)): $($failed -join ', ')" -ForegroundColor Red
    exit 1
}
Write-Host "All tests passed." -ForegroundColor Green
exit 0
