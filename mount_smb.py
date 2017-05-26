import shutil, subprocess
import socket
import time

#We'll wait 30 sec to make sure everything is up and running...
time.sleep(30)
smb_ip=socket.gethostbyname("milkyway-smb")

corrected_smb_ip=smb_ip.rsplit(".",1)[0]+str(int(smb_ip.rsplit(".",1)[1])+1)

shutil.rmtree("C:\\pulsar\\files\\staging")
try:
    subprocess.call(r'net use \\\\{0}\\allusers\\'.format(corrected_smb_ip))
    subprocess.call(r'mklink /d '+'\\\\{0}\\allusers\\ '.format(corrected_smb_ip)+'C:\\pulsar\\files\\staging')
except:
    #maybe this host has patched the problem?
    subprocess.call(r'net use \\\\{0}\\allusers\\'.format(smb_ip))
    subprocess.call(r'mklink /d '+'\\\\{0}\\allusers\\ '.format(smb_ip)+'C:\\pulsar\\files\\staging')
	
