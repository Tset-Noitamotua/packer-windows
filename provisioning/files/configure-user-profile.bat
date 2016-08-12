
:: Enable autologon
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 1 /f

:: Change Aero theme to classic theme
%SystemRoot%\system32\rundll32.exe %SystemRoot%\system32\shell32.dll,Control_RunDLL %SystemRoot%\system32\desk.cpl desk,@Themes /Action:OpenTheme /file:"C:\Windows\Resources\Ease of Access Themes\classic.theme"

:: Disable task grouping in taskbar
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoTaskGrouping /t REG_DWORD /d 1 /f
