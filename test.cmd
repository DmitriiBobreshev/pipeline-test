set arg1=%1
set arg2=%2
CALL "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.com" "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp.sln" /log "%arg2%\msi_log.xml" /out "%arg2%\out.txt" /Build "Release" /Project "%arg1%\LegacyWindowsFormsApp/BlastFromThePastSetup/BlastFromThePastSetup.vdproj"
