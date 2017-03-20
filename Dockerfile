FROM microsoft/dotnet-framework

MAINTAINER William Barshop, wbarshop@ucla.edu

RUN powershell -nologo -noprofile -command "& { iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex }";
RUN powershell -nologo -noprofile -command "& { choco install git 7zip.install python2 nuget.commandline gow -y}";

COPY Skyline-daily C:\skyline
COPY SkylineDailyRunner.exe C:\skyline\SkylineDailyRunner.exe
COPY peak_boundaries.skyr C:\skyline\peak_boundaries.skyr
COPY WOHL_MSSTATS_REPORT.skyr C:\skyline\WOHL_MSSTATS_REPORT.skyr

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
COPY pwiz-setup-3.0.10577-x86.msi C:/skyline/pwiz-setup-3.0.10577-x86.msi

RUN msiexec /i C:/skyline/pwiz-setup-3.0.10577-x86.msi

#Patch listed in https://github.com/galaxyproject/pulsar/issues/125 for directory issues...
RUN sed -i "s#        pattern = r\"(%s%s\S+)\" % (directory, sep)#        directory = directory.replace('\\','\\\\')\n        pattern = r\"(%s%s\S+)\" % (directory, sep)#g"

#Default startup command...
CMD ["C:/pulsar/venv/Scripts/activate.bat && run.bat"]
