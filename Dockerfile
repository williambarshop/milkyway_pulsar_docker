FROM microsoft/dotnet-framework:3.5
MAINTAINER William Barshop, wbarshop@ucla.edu

RUN ["powershell","-Command","iwr","https://chocolatey.org/install.ps1","-UseBasicParsing","|","iex"]
#RUN powershell -nologo -noprofile -command choco install 7zip.portable -y
RUN powershell -nologo -noprofile -command choco install 7zip.portable git python2 nuget.commandline gow vcredist2008 vcredist2013 vcredist2015 --execution-timeout 3500 -y
#RUN powershell -nologo -noprofile -command choco install dotnet4.7.2 --execution-timeout 3500 -y

#Install skyline and add it to the path
WORKDIR C:/ 
RUN mkdir skyline
WORKDIR C:/skyline


#Skyline stable 3.7 11357 download and extract...
#RUN wget http://teamcity.labkey.org:8080/guestAuth/repository/download/ProteoWizard_WindowsX8664SkylineReleaseBranchMsvcProfessional/486243:id/SkylineTester.zip
#RUN wget http://teamcity.labkey.org:8080/guestAuth/repository/download/ProteoWizard_WindowsX8664SkylineReleaseBranchMsvcProfessional/531026:id/SkylineTester.zip
#RUN powershell -nologo -noprofile -command "& 7z.exe e SkylineTester.zip -y"
RUN curl -L -k https://skyline.ms/_webdav/home/software/Skyline/%40files/installers/Skyline-64_4_1_0_18163.zip > skyline.zip
#COPY Skyline-daily-64_4_0_9_11707.zip C:/skyline/skyline.zip
#COPY Skyline-64_4_1_0_11714.zip C:/skyline/skyline.zip
RUN powershell -nologo -noprofile -command "& 7z.exe e skyline.zip -y"


RUN del Skyline-daily.exe.config
RUN del Skyline.exe.config
COPY Skyline-daily.exe.config C:/skyline/SkylineCmd.exe.config
COPY Skyline-daily.exe.config C:/skyline/Skyline-Daily.exe.config
COPY Skyline-daily.exe.config C:/skyline/Skyline.exe.config
COPY WOHL_MSSTATS_REPORT.skyr C:/skyline/
COPY peak_boundaries.skyr C:/skyline/
RUN powershell -command $oldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path;$newPath=$oldPath+’;C:\skyline\’;Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath

#We're going to grab pigz and add it to the skyline folder to keep it in the path...
#RUN wget --no-check-certificate https://downloads.sourceforge.net/project/pigzforwindows/pigz-2.3-bin-win32.zip
RUN curl -L -k https://downloads.sourceforge.net/project/pigzforwindows/pigz-2.3-bin-win32.zip > pigz-2.3-bin-win32.zip
RUN powershell -nologo -noprofile -command "& 7z.exe e pigz-2.3-bin-win32.zip -y"

#Let's set up the virtualenv and install pulsar.
RUN pip install virtualenv
#RUN C:/pulsar/venv/Scripts/activate.bat && pip install pulsar-app && pulsar-config
WORKDIR C:/
#Clone pulsar from github...
RUN git clone https://github.com/galaxyproject/pulsar && cd pulsar && powershell -command virtualenv venv
#git checkout a9e590132ddb3ccb61d8d2253855dbfa409fcd94 &&
WORKDIR C:/pulsar
#We'll set up Pulsar in this directory... and then alter the host IP access to the pulsar server.
#pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U &&
#&& pip install --trusted-host pypi.python.org conda
RUN C:/pulsar/venv/Scripts/activate.bat  && pip install --upgrade pip && pip install -r requirements.txt && pip install -r dev-requirements.txt && pip install win-unicode-console pulsar-app xmltodict xml2dict natsort pandas numpy uniprot_tools pyteomics protobuf && copy app.yml.sample app.yml
RUN sed -i "s/host = localhost/host = 0.0.0.0/g" server.ini.sample
#Set to four concurrent jobs with app.yml
COPY app.yml C:/pulsar/app.yml

#Patch listed in https://github.com/galaxyproject/pulsar/issues/125 for directory issues...
RUN sed -i "s#        pattern = r\"(#        directory = directory.replace('\\\\','\\\\\\\\')\n        pattern = r\"(#g" C:\\pulsar\\pulsar\\client\\staging\\up.py

#RUN wget 'http://teamcity.labkey.org:8080/repository/download/bt36/.lastSuccessful/pwiz-setup-'$(wget -O- http://teamcity.labkey.org:8080/repository/download/bt36/.lastSuccessful/VERSION?guest=1)'-x86.msi?guest=1'

WORKDIR C:/
RUN mkdir pwiz

COPY pwiz-setup-3.0.11383-x86_64.msi C:/pwiz/pwiz.msi
WORKDIR C:/pwiz/
#RUN wget http://teamcity.labkey.org:8080/guestAuth/repository/download/bt83/490407:id/pwiz-setup-3.0.11383-x86_64.msi
#RUN wget http://teamcity.labkey.org/guestAuth/repository/download/bt83/551603:id/pwiz-setup-3.0.11806-x86_64.msi
#RUN wget http://teamcity.labkey.org/guestAuth/repository/download/bt83/604364:id/pwiz-setup-3.0.18199.78f1f2280-x86_64.msi
#RUN wget http://teamcity.labkey.org/guestAuth/repository/download/bt83/610534:id/pwiz-setup-3.0.18215.f6864290f-x86_64.msi
#RUN dir
#RUN wget http://teamcity.labkey.org/guestAuth/repository/download/bt83/619675:id/pwiz-setup-3.0.18236.f495f9016-x86_64.msi
#RUN wget http://teamcity.labkey.org/guestAuth/repository/download/bt83/666576:id/pwiz-setup-3.0.18337.a35d6ec04-x86_64.msi
#RUN sleep 601
RUN ["cmd","/S","/C","C:\\Windows\\syswow64\\msiexec.exe","/i","C:\\pwiz\\pwiz.msi","/qb"]

###WHEN YOU UPDATE PWIZ, MAKE SURE TO UPDATE $PATH SETTING BELOW


WORKDIR C:/pulsar
RUN rmdir /S /Q C:\pwiz
RUN powershell -command $oldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path;$newPath=$oldPath+’;C:\Program Files\ProteoWizard\ProteoWizard 3.0.11383\’;Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath


#Windows 'G:' drive workaround (see https://blog.sixeyed.com/docker-volumes-on-windows-the-case-of-the-g-drive/ )
#VOLUME C:/pulsardata/
VOLUME C:/pulsar/files/staging
#RUN powershell -command Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices' -Name 'G:' -Value "\??\C:\pulsardata" -Type String;
#COPY execute.py C:/pulsar/execute.py

#Default startup command...
#CMD ["python execute.py"]
CMD ["C:/pulsar/venv/Scripts/activate.bat && C:/pulsar/run.bat"]