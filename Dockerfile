FROM microsoft/dotnet-framework:3.5
MAINTAINER William Barshop, wbarshop@ucla.edu

RUN ["powershell","-Command","iwr","https://chocolatey.org/install.ps1","-UseBasicParsing","|","iex"]
#RUN powershell -nologo -noprofile -command choco install 7zip.portable -y
RUN powershell -nologo -noprofile -command choco install 7zip.portable git python2 nuget.commandline gow vcredist2008 vcredist2013 vcredist2015 --execution-timeout 3500 -y


WORKDIR C:/ 
RUN mkdir skyline
WORKDIR C:/skyline
COPY Skyline-daily-64_3_6_1_10690.zip C:/skyline/
RUN powershell -nologo -noprofile -command "& 7z.exe e Skyline-daily-64_3_6_1_10690.zip -y"
RUN del Skyline-daily.exe.config
COPY Skyline-daily.exe.config C:/skyline/
COPY WOHL_MSSTATS_REPORT.skyr C:/skyline/
COPY peak_boundaries.skyr C:/skyline/

#Let's set up the virtualenv and install pulsar.
RUN pip install virtualenv
#RUN C:/pulsar/venv/Scripts/activate.bat && pip install pulsar-app && pulsar-config
WORKDIR C:/
#Clone pulsar from github...
RUN git clone https://github.com/galaxyproject/pulsar && cd pulsar && powershell -command virtualenv venv
WORKDIR C:/pulsar
#We'll set up Pulsar in this directory... and then alter the host IP access to the pulsar server.
RUN C:/pulsar/venv/Scripts/activate.bat && pip install -r requirements.txt && pip install -r dev-requirements.txt && pip install pulsar-app xml2dict natsort pandas numpy uniprot_tools && copy app.yml.sample app.yml
RUN sed -i "s/host = localhost/host = 0.0.0.0/g" server.ini.sample
#Patch listed in https://github.com/galaxyproject/pulsar/issues/125 for directory issues...
RUN sed -i "s#        pattern = r#        directory = directory.replace('\\\\','\\\\\\\\')\n        pattern = r#g" C:\\pulsar\\pulsar\\client\\staging\\up.py

#RUN wget 'http://teamcity.labkey.org:8080/repository/download/bt36/.lastSuccessful/pwiz-setup-'$(wget -O- http://teamcity.labkey.org:8080/repository/download/bt36/.lastSuccessful/VERSION?guest=1)'-x86.msi?guest=1'

WORKDIR C:/
RUN mkdir pwiz

COPY pwiz-setup-3.0.10577-x86.msi C:/pwiz/pwiz.msi
WORKDIR C:/pwiz/

RUN ["cmd","/S","/C","C:\\Windows\\syswow64\\msiexec.exe","/i","C:\\pwiz\\pwiz.msi","/qb"]
WORKDIR C:/pulsar
RUN rmdir /S /Q C:\pwiz
RUN powershell -command $oldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path;$newPath=$oldPath+’;C:\Program Files (x86)\ProteoWizard\ProteoWizard 3.0.10577\’;Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $newPath

#Default startup command...

CMD ["C:/pulsar/venv/Scripts/activate.bat && run.bat"]
