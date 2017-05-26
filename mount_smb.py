import shutil, subprocess
import socket
import time

#We'll wait 30 sec to make sure everything is up and running...
time.sleep(30)
smb_ip=socket.gethostbyname("milkyway-smb")

corrected_smb_ip=smb_ip.rsplit(".",1)[0]+"."+str(int(smb_ip.rsplit(".",1)[1])+1)
#print corrected_smb_ip
shutil.rmtree("C:\\pulsar\\files\\staging")
try:
    subprocess.call('net use \\\\{0}\\allusers /user:test test'.format(corrected_smb_ip))
	time.sleep(30)
    subprocess.call('mklink /d '+'C:\\pulsar\\files\\staging '+'\\\\{0}\\allusers '.format(corrected_smb_ip),shell=True)
except:
    #maybe this host has patched the problem?
	subprocess.call('net use \\\\{0}\\allusers /user:test test'.format(smb_ip))
	time.sleep(30)
    subprocess.call('mklink /d '+'C:\\pulsar\\files\\staging '+'\\\\{0}\\allusers '.format(smb_ip),shell=True)