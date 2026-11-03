@echo off
REM Windows runner. Usage: scripts\run_test.bat [smoke|load|stress]
setlocal
set PROFILE=%1
if "%PROFILE%"=="" set PROFILE=smoke

if /I "%PROFILE%"=="smoke"  (set USERS=5   & set RAMPUP=10  & set DURATION=60)
if /I "%PROFILE%"=="load"   (set USERS=50  & set RAMPUP=60  & set DURATION=300)
if /I "%PROFILE%"=="stress" (set USERS=150 & set RAMPUP=120 & set DURATION=300)

set ROOT=%~dp0..
set STAMP=%DATE:~-4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set STAMP=%STAMP: =0%
set OUT=%ROOT%\results\%PROFILE%_%STAMP%
mkdir "%OUT%"

jmeter -n -t "%ROOT%\test-plans\blazedemo_load_test.jmx" ^
  -Jusers=%USERS% -Jrampup=%RAMPUP% -Jduration=%DURATION% ^
  -Jdata_dir="%ROOT%\data" ^
  -l "%OUT%\results.jtl" -j "%OUT%\jmeter.log" -e -o "%OUT%\report"

python "%ROOT%\scripts\summarize_results.py" "%OUT%\results.jtl" --markdown "%OUT%\summary.md"
echo Done. Open %OUT%\report\index.html
endlocal
