#FROM microsoft/windowsservercore
FROM microsoft/dotnet-framework:3.5
MAINTAINER William Barshop, wbarshop@ucla.edu

#RUN powershell -Command iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
RUN ["powershell","-Command","iwr","https://chocolatey.org/install.ps1","-UseBasicParsing","|","iex"]
#RUN powershell -command Install-PackageProvider NanoServerPackage
#RUN powershell -command Import-PackageProvider NanoServerPackage ; 
#RUN powershell -command Find-NanoServerPackage
#RUN powershell -command Save-NanoServerPackage
#RUN powershell -command Install-NanoServerPackage

#RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH="%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
#RUN powershell -command Install-WindowsFeature -Name Net-Framework-Features
#RUN powershell -command Install-WindowsFeature -Name Net-Framework-Core
RUN powershell -nologo -noprofile -command choco install git 7zip.install python2 nuget.commandline gow vcredist2008 vcredist2013 vcredist2015 --execution-timeout 3500 -y
#visualstudio2013professional vcredist2008 vcredist2013 vcredist2015 vcredist2017 boost-msvc-12 ###  visualstudio2015community vcbuildtools microsoft-build-tools cmake.install visualcppbuildtools

WORKDIR C:/ 
RUN mkdir skyline
WORKDIR C:/skyline
COPY Skyline-daily-64_3_6_1_10615.zip C:/skyline/
RUN powershell -nologo -noprofile -command "& 'C:/Program Files/7-zip/7z.exe' e Skyline-daily-64_3_6_1_10615.zip -y"
COPY WOHL_MSSTATS_REPORT.skyr C:/skyline/
COPY peak_boundaries.skyr C:/skyline/
#RUN dir

#COPY Skyline-daily C:\skyline
#COPY SkylineDailyRunner.exe C:\skyline\SkylineDailyRunner.exe

#Let's set up the virtualenv and install pulsar.
RUN pip install virtualenv
#RUN C:/pulsar/venv/Scripts/activate.bat && pip install pulsar-app && pulsar-config
WORKDIR C:/
#Clone pulsar from github...
RUN git clone https://github.com/galaxyproject/pulsar && cd pulsar && powershell -command virtualenv venv
WORKDIR C:/pulsar
#We'll set up Pulsar in this directory... and then alter the host IP access to the pulsar server.
RUN C:/pulsar/venv/Scripts/activate.bat && pip install -r requirements.txt && pip install -r dev-requirements.txt && pip install pulsar-app && copy app.yml.sample app.yml
RUN sed -i "s/host = localhost/host = 0.0.0.0/g" server.ini.sample
#Patch listed in https://github.com/galaxyproject/pulsar/issues/125 for directory issues...
RUN sed -i "s#        pattern = r\"(%s%s\S+)\" % (directory, sep)#        directory = directory.replace('\\','\\\\')\n        pattern = r\"(%s%s\S+)\" % (directory, sep)#g" C:\\pulsar\\pulsar\\client\\staging\\up.py

#RUN wget 'http://teamcity.labkey.org:8080/repository/download/bt36/.lastSuccessful/pwiz-setup-'$(wget -O- http://teamcity.labkey.org:8080/repository/download/bt36/.lastSuccessful/VERSION?guest=1)'-x86.msi?guest=1'

WORKDIR C:/
RUN mkdir pwiz
#COPY pwiz-bin-windows-x86_64-vc120-release-3_0_10577.tar.bz2 C:/pwiz/pwiz.tar.bz2
COPY pwiz-setup-3.0.10577-x86.msi C:/pwiz/pwiz.msi
WORKDIR C:/pwiz/
##RUN ["C:/Program Files/7-zip/7z.exe","e","pwiz-src-3_0_10577.tar.bz2"]
#RUN ["C:/Program Files/7-zip/7z.exe","e","pwiz.tar.bz2"]
#RUN powershell -nologo -noprofile -command "& 'C:/Program Files/7-zip/7z.exe' e pwiz.tar -y"
#RUN powershell -command Start-Process -FilePath C:/pwiz/pwiz.msi -ArgumentList '/qn' -PassThru -Wait
RUN ["cmd","/S","/C","C:\\Windows\\syswow64\\msiexec.exe","/i","C:\\pwiz\\pwiz.msi","/qb"]
#RUN del pwiz.tar.bz2 && del pwiz.tar
RUN dir
#RUN quickbuild.bat

RUN set PATH='%PATH%;C:/pwiz/'


#COPY ./pwiz-setup-3.0.10577-x86.msi C:/pulsar/pwiz.msi
#Run net user administrator password
#Run net user administrator /active:yes
#RUN powershell -command Start-Process -FilePath C:\\Windows\\System32\\msiexec.exe -ArgumentList '/i C:\\pulsar\\pwiz*.msi /qn /l*+v install.log' -PassThru -Wait
#RUN ["cmd","/S","/C","C:\\Windows\\syswow64\\msiexec.exe","/i","C:\\pulsar\\pwiz.msi","/qb"]
#RUN powershell -command Start-Process -FilePath C:\\pulsar\\pwiz.msi -ArgumentList '/qn' -PassThru -Wait
#RUN ["C:\\windows\\system32\\msiexec.exe","/i","C:\\pulsar\\pwiz.msi","/qn","/passive"]




#Default startup command...
WORKDIR C:/pulsar
CMD ["C:/pulsar/venv/Scripts/activate.bat && run.bat"]
