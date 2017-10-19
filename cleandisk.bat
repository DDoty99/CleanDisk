@echo off
@echo off & setlocal ENABLEDELAYEDEXPANSION
SET "volume=C:"
FOR /f "tokens=1*delims=:" %%i IN ('fsutil volume diskfree %volume%') DO (
    SET "diskfree=!disktotal!"
    SET "disktotal=!diskavail!"
    SET "diskavail=%%j"
)
echo "DiskCleanup2Quick"

SET /a diskused=%disktotal:~0,-9% - %diskavail:~0,-9%
ECHO(Information for volume %volume%
ECHO(TOTAL SIZE  ---------- %disktotal:~0,-9% GB
ECHO(AVAILABLE SIZE ------- %diskavail:~0,-9% GB
ECHO(USED SIZE ------------ %diskused% GB



:: Previous Windows versions cleanup. These are left behind after upgrading an installation from XP/Vista/7/8 to a higher version
if exist %SystemDrive%\Windows.old\ (
	takeown /F %SystemDrive%\Windows.old\* /R /A /D Y
	echo y| cacls %SystemDrive%\Windows.old\*.* /C /T /grant administrators:F
	rmdir /S /Q %SystemDrive%\Windows.old\
	)
if exist %SystemDrive%\$Windows.~BT\ (
	takeown /F %SystemDrive%\$Windows.~BT\* /R /A
	icacls %SystemDrive%\$Windows.~BT\*.* /T /grant administrators:F
	rmdir /S /Q %SystemDrive%\$Windows.~BT\
	)
if exist %SystemDrive%\$Windows.~WS (
	takeown /F %SystemDrive%\$Windows.~WS\* /R /A
	icacls %SystemDrive%\$Windows.~WS\*.* /T /grant administrators:F
	rmdir /S /Q %SystemDrive%\$Windows.~WS\
	)

	
	for /D %%x in ("%SystemDrive%\Users\*") do (
		del /F /S /Q "%%x\*.blf" 2>NUL
		del /F /S /Q "%%x\*.regtrans-ms" 2>NUL
		del /F /S /Q "%%x\AppData\LocalLow\Sun\Java\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\Cache\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\JumpListIconsOld\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\JumpListIcons\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\Local Storage\http*.*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Google\Chrome\User Data\Default\Media Cache\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Internet Explorer\Recovery\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Terminal Server Client\Cache\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\Caches\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\Explorer\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\History\low\*" /AH 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\INetCache\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\WER\ReportArchive\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\WER\ReportQueue\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Microsoft\Windows\WebCache\*" 2>NUL
		del /F /S /Q "%%x\AppData\Local\Temp\*" 2>NUL
		del /F /S /Q "%%x\AppData\Roaming\Adobe\Flash Player\*" 2>NUL
		del /F /S /Q "%%x\AppData\Roaming\Macromedia\Flash Player\*" 2>NUL
		del /F /S /Q "%%x\AppData\Roaming\Microsoft\Windows\Recent\*" 2>NUL
		del /F /S /Q "%%x\Recent\*" 2>NUL
		del /F /Q "%%x\Documents\*.tmp" 2>NUL
	)


::::::::::::::::::::::
:: Version-agnostic :: (these jobs run regardless of OS version)
::::::::::::::::::::::
:: JOB: System temp files
del /F /S /Q "%WINDIR%\TEMP\*" 2>NUL

:: JOB: Root drive garbage (usually C drive)
rmdir /S /Q %SystemDrive%\Temp 2>NUL
for %%i in (bat,txt,log,jpg,jpeg,tmp,bak,backup,exe) do (
	del /F /Q "%SystemDrive%\*.%%i" 2>NUL
)

:: JOB: Remove files left over from installing Nvidia/ATI/AMD/Dell/Intel/HP drivers
for %%i in (NVIDIA,ATI,AMD,Dell,Intel,HP,OEM) do (
	rmdir /S /Q "%SystemDrive%\%%i" 2>NUL
)

:: JOB: Clear additional unneeded files from NVIDIA driver installs
if exist "%ProgramFiles%\Nvidia Corporation\Installer2" rmdir /s /q "%ProgramFiles%\Nvidia Corporation\Installer2"
if exist "%ALLUSERSPROFILE%\NVIDIA Corporation\NetService" del /f /q "%ALLUSERSPROFILE%\NVIDIA Corporation\NetService\*.exe"

:: JOB: Remove the Office installation cache. Usually around ~1.5 GB
if exist %SystemDrive%\MSOCache rmdir /S /Q %SystemDrive%\MSOCache

:: JOB: Remove the Windows installation cache. Can be up to 1.0 GB
if exist %SystemDrive%\i386 rmdir /S /Q %SystemDrive%\i386

:: JOB: Empty all recycle bins on Windows 5.1 (XP/2k3) and 6.x (Vista and up) systems
if exist %SystemDrive%\RECYCLER rmdir /s /q %SystemDrive%\RECYCLER
if exist %SystemDrive%\$Recycle.Bin rmdir /s /q %SystemDrive%\$Recycle.Bin

:: JOB: Clear MUI cache
reg delete "HKCU\SOFTWARE\Classes\Local Settings\Muicache" /f

:: JOB: Clear Windows Search Temp Data
if exist "%ALLUSERSPROFILE%\Microsoft\Search\Data\Temp" rmdir /s /q "%ALLUSERSPROFILE%\Microsoft\Search\Data\Temp"

:: JOB: Windows update logs & built-in backgrounds (space waste)
del /F /Q %WINDIR%\*.log 2>NUL
del /F /Q %WINDIR%\*.txt 2>NUL
del /F /Q %WINDIR%\*.bmp 2>NUL
del /F /Q %WINDIR%\*.tmp 2>NUL


:: JOB: Windows CBS logs
::      these only exist on Vista and up, so we look for "Microsoft", and assuming we don't find it, clear out the folder
del /F /Q %WINDIR%\Logs\CBS\* 2>NUL


rundll32.exe inetcpl.cpl,ClearMyTracksByProcess 4351
net stop WUAUSERV
	if exist %windir%\softwaredistribution\download rmdir /s /q %windir%\softwaredistribution\download
	net start WUAUSERV
@echo off & setlocal ENABLEDELAYEDEXPANSION
SET "volume=C:"
FOR /f "tokens=1*delims=:" %%i IN ('fsutil volume diskfree %volume%') DO (
    SET "diskfree=!disktotal!"
    SET "disktotal=!diskavail!"
    SET "diskavail=%%j"
)
echo "DiskCleanup2Quick"

SET /a diskused=%disktotal:~0,-9% - %diskavail:~0,-9%
ECHO(Information for volume %volume%
ECHO(TOTAL SIZE  ---------- %disktotal:~0,-9% GB
ECHO(AVAILABLE SIZE ------- %diskavail:~0,-9% GB
ECHO(USED SIZE ------------ %diskused% GB
echo --------------------------------------------------------------------------------------------
echo %CUR_DATE% %TIME%  TempFileCleanup finished. Executed as %USERDOMAIN%\%USERNAME%
echo --------------------------------------------------------------------------------------------
echo.
