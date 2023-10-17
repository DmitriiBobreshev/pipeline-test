set arg1=%1
set arg2=%2
@REM CALL "C:\%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.com" "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp.sln" /log "%arg2%\msi_log.xml" /out "%arg2%\out.txt" /Build "Release" /Project "%arg1%\LegacyWindowsFormsApp/LegacyWindowsFormsApp/LegacyWindowsFormsApp.csproj"
@REM CALL "C:\%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.com" "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp.sln" /log "%arg2%\msi_log.xml" /out "%arg2%\out.txt" /Build "Release" /Project "%arg1%\LegacyWindowsFormsApp/BlastFromThePastSetup/BlastFromThePastSetup.vdproj"

@REM CALL "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.com" "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp.sln" /log "%arg2%\msi_log.xml" /out "%arg2%\out.txt" /Build "Release" /Project "%arg1%\LegacyWindowsFormsApp/LegacyWindowsFormsApp/LegacyWindowsFormsApp.csproj"
@REM CALL "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.com" "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp.sln" /log "%arg2%\msi_log.xml" /out "%arg2%\out.txt" /Build "Release" /Project "%arg1%\LegacyWindowsFormsApp/BlastFromThePastSetup/BlastFromThePastSetup.vdproj"


@REM exit %errorLevel%

for /l %%i in (1,1,10) do (
  echo Iteration %%i
  rmdir /s /q "%arg1%\LegacyWindowsFormsApp\.vs"
  rmdir /s /q "%arg1%\LegacyWindowsFormsApp\BlastFromThePastSetup\Debug"
  rmdir /s /q "%arg1%\LegacyWindowsFormsApp\BlastFromThePastSetup\Release"
  rmdir /s /q "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp\bin"
  rmdir /s /q "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp\obj"
  CALL "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.com" "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp.sln" /log "%arg2%\msi_log.xml" /out "%arg2%\out.txt" /Build "Release" /Project "%arg1%\LegacyWindowsFormsApp/BlastFromThePastSetup/BlastFromThePastSetup.vdproj"
  timeout /t 1
)

exit %errorLevel%
