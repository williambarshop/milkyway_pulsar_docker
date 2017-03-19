FROM microsoft/dotnet-framework

MAINTAINER William Barshop, wbarshop@ucla.edu

RUN powershell -nologo -noprofile -command "& { iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex }";
RUN powershell -nologo -noprofile -command "& { choco install git 7zip.install python2 nuget.commandline gow -y}"; #curl
#RUN powershell -nologo -noprofile -command "& {cd /; $client = New-Object System.Net.Webclient; $client.DownloadFile('https://skyline.ms/labkey/files/home/software/Skyline/daily/Skyline-daily-64_3_6_1_10556.zip','C:\Skyline-daily.zip'); }";


COPY Skyline-daily C:\skyline
COPY SkylineDailyRunner.exe C:\skyline\SkylineDailyRunner.exe
COPY peak_boundaries.skyr C:\skyline\peak_boundaries.skyr
COPY WOHL_MSSTATS_REPORT.skyr C:\skyline\WOHL_MSSTATS_REPORT.skyr

#Let's set up the virtualenv and install pulsar.
RUN pip install virtualenv
#RUN powershell -nologo -noprofile -command "& { mkdir pulsar;cd pulsar;virtualenv venv; source venv\Scripts\activate; pip install pulsar-app }";
#RUN powershell -command md pulsar
#["md","pulsar"]

#RUN C:/pulsar/venv/Scripts/activate.bat && pip install pulsar-app && pulsar-config
WORKDIR C:/
RUN git clone https://github.com/galaxyproject/pulsar && cd pulsar && powershell -command virtualenv venv
WORKDIR C:/pulsar
RUN C:/pulsar/venv/Scripts/activate.bat && pip install -r requirements.txt && pip install -r dev-requirements.txt && pip install pulsar-app && copy app.yml.sample app.yml
RUN sed -i "s/host = localhost/host = 0.0.0.0/g" server.ini.sample && sed -i "s/#private_token: changemeinproduction/private_token: ChangeThisPassphrase12345/g" app.yml

#CMD ["C:/pulsar/venv/Scripts/activate.bat","&&","pulsar"]
#RUN dir && dir


#CMD ["powershell -nologo -noprofile -command \"& { C:/pulsar/venv/Scripts/activate.bat ; pulsar }\""]

COPY pwiz-setup-3.0.10577-x86.exe C:\skyline\pwiz-setup-3.0.10577-x86.exe

RUN msiexec /i C:\skyline\pwiz-setup-3.0.10577-x86.exe 


CMD ["C:/pulsar/venv/Scripts/activate.bat && run.bat"]












#Let's also go ahead and install Docker in here...
#RUN powershell -command Install-WindowsFeature Hyper-V && Install-Module -Name DockerMsftProvider -Repository PSGallery -Force && Install-Package -Name docker -ProviderName DockerMsftProvider
#RUN powershell -command "& {Install-Module -Name DockerMsftProvider -Repository PSGallery -Force ; Install-Package -Name docker -ProviderName DockerMsftProvider; }";

#WORKDIR C:/
#RUN powershell -nologo -noprofile -command "&{ $client = New-Object System.Net.Webclient; $client.DownloadFile('https://download.docker.com/win/stable/InstallDocker.msi','InstallDocker.msi')}";
# /qn /norestart /l*v'
#RUN msiexec.exe /I InstallDocker.msi /qn /norestart
#/l*v

#RUN docker



#RUN 'C:\Program Files\7-Zip\7z.exe' x "C:\\skyline-daily.zip"

#RUN powershell -command "& {cd /; Add-Type -A 'System.IO.Compression.FileSystem';[IO.Compression.ZipFile]::ExtractToDirectory('skyline-daily.zip'); }";
#RUN powershell -nologo -noprofile -command "& {cd /; $shell = new-object -com shell.application;$zip_file=$shell.Namespace('C:/Skyline-daily-64_3_6_1_10556.zip');foreach($item in $zip.items()){$shell.Namespace('C:\skyline').copyhere($item)} }";
#RUN powershell -nologo -noprofile -command "& { Import-Module Servermanager ; Add-WindowsFeature NET-Framework-Core,NET-Framework-Features}";
#RUN powershell mkdir skyline-app/
#RUN copy "skyline/Skyline-64_3_6_0_10493/Application Files/Skyline_3_6_0_10493/" "skyline-app/"
#RUN powershell (new-object System.Net.WebClient).DownloadFile('https://skyline.ms/wiki/home/software/Skyline/daily/download.view?entityId=4264489e-572f-102f-a8bb-da20258202b3"&"name=SkylineDailyRunner.exe','SkylineDailyRunner.exe');
#skyline\Skyline-64_3_6_0_10493\setup.exe /s /x /b"skyline/WorkingDir" /v"/qn"
#powershell -nologo -noprofile -command "& { register-packagesource -Name chocolatey -Provider PSModule -Trusted -Location http://chocolatey.org/api/v2/ -Verbose ;Install-Package git}";



#powershell wget https://github.com/git-for-windows/git/releases/download/v2.12.0.windows.1/Git-2.12.0-64-bit.exe;
#powershell (new-object System.Net.WebClient).DownloadFile('https://github.com/git-for-windows/git/releases/download/v2.12.0.windows.1/Git-2.12.0-64-bit.exe','github.exe');



