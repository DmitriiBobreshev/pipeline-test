set arg1=%1
set arg2=%2
CALL "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe" "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp.sln" /log "%arg2%\msi_log.xml" /out "%arg2%\out.txt" /Build "Release" /Project "%arg1%\LegacyWindowsFormsApp/BlastFromThePastSetup/BlastFromThePastSetup.vdproj"
