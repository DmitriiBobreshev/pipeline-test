set arg1=%1
set arg2=%2
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.com" "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp.sln" /log "%arg2%\msi_log.xml" /out "%arg2%\out.txt" /Build "Debug" /Project "%arg1%\LegacyWindowsFormsApp/LegacyWindowsFormsApp/LegacyWindowsFormsApp.csproj"
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.com" "%arg1%\LegacyWindowsFormsApp\LegacyWindowsFormsApp.sln" /log "%arg2%\msi_log.xml" /out "%arg2%\out.txt" /Build "Debug" /Project "%arg1%\LegacyWindowsFormsApp/BlastFromThePastSetup/BlastFromThePastSetup.vdproj"

exit %errorLevel%