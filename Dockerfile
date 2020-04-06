FROM chambm/pwiz-skyline-i-agree-to-the-vendor-licenses
MAINTAINER William Barshop, wbarshop@ucla.edu

RUN sudo apt-get update && sudo apt-get install \
     p7zip-full pigz virtualenv \
	 gcc git build-essential \
     python3 python-dev python3-dev \
     build-essential libssl-dev libffi-dev \
     libxml2-dev libxslt1-dev zlib1g-dev \
	 libcurl4-openssl-dev \
     python-pip python3-venv -y
	 
RUN mkdir /skyline/
COPY WOHL_MSSTATS_REPORT.skyr /skyline/
COPY peak_boundaries.skyr /skyline/

RUN cd / && git clone https://github.com/galaxyproject/pulsar && cd pulsar && git checkout 3e664ea7c6fcecc0a964eef589443e760d151488
WORKDIR /pulsar/

#We'll set up Pulsar in this directory... and then alter the host IP access to the pulsar server.
#We also will set up the dependencies needed.
RUN python3 -m venv venv && . venv/bin/activate && \
     pip3 install --upgrade pip setuptools && \
     pip3 install pulsar-app \
	 xmltodict xml2dict natsort \
	 pandas numpy uniprot_tools \
	 pyteomics protobuf && \
	 pip3 install -r requirements.txt 

#Set to listen on all interfaces
RUN sed -i "s/host = localhost/host = 0.0.0.0/g" server.ini.sample

#Set to four concurrent jobs with app.yml
COPY app.yml /pulsar/app.yml

# Default execution entry...
CMD sh -c ". /pulsar/venv/bin/activate && /pulsar/run.sh"