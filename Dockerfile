FROM microsoft/windowsservercore

MAINTAINER William Barshop, wbarshop@ucla.edu

RUN powershell -nologo -noprofile -command "& { iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex }";
RUN powershell -nologo -noprofile -command "& { choco install git 7zip.install -y}";
#RUN powershell -nologo -noprofile -command "& {cd /; $client = New-Object System.Net.Webclient; $client.DownloadFile('https://skyline.ms/labkey/files/home/software/Skyline/daily/Skyline-daily-64_3_6_1_10556.zip','C:\Skyline-daily.zip'); }";


COPY Skyline-daily-64_3_6_1_10556.zip C:\Skyline-daily.zip
RUN powershell -command "& {cd /; 'C:\Program Files\7-Zip\7z.exe' e C:/Skyline-daily.zip ; }";

#RUN powershell -nologo -noprofile -command "& {cd /; Add-Type -A 'System.IO.Compression.FileSystem';[IO.Compression.ZipFile]::ExtractToDirectory('Skyline-daily.zip'); }";
#RUN powershell -nologo -noprofile -command "& {cd /; $shell = new-object -com shell.application;$zip_file=$shell.Namespace('C:/Skyline-daily.zip');foreach($item in $zip.items()){$shell.Namespace('C:\skyline').copyhere($item)} }";
RUN powershell -nologo -noprofile -command "& { Import-Module Servermanager ; Add-WindowsFeature NET-Framework-Core,NET-Framework-Features}";
RUN powershell mkdir skyline-app/
RUN cp "skyline/Skyline-64_3_6_0_10493/Application Files/Skyline_3_6_0_10493/" "skyline-app/"
RUN powershell (new-object System.Net.WebClient).DownloadFile('https://skyline.ms/wiki/home/software/Skyline/daily/download.view?entityId=4264489e-572f-102f-a8bb-da20258202b3"&"name=SkylineDailyRunner.exe','SkylineDailyRunner.exe');
#skyline\Skyline-64_3_6_0_10493\setup.exe /s /x /b"skyline/WorkingDir" /v"/qn"
#powershell -nologo -noprofile -command "& { register-packagesource -Name chocolatey -Provider PSModule -Trusted -Location http://chocolatey.org/api/v2/ -Verbose ;Install-Package git}";



#powershell wget https://github.com/git-for-windows/git/releases/download/v2.12.0.windows.1/Git-2.12.0-64-bit.exe;
#powershell (new-object System.Net.WebClient).DownloadFile('https://github.com/git-for-windows/git/releases/download/v2.12.0.windows.1/Git-2.12.0-64-bit.exe','github.exe');



