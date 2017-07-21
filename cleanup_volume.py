import shutil, os
import time

#We'll wait 5 sec to make sure everything is up and running...
time.sleep(5)
source_dir = "C:\\pulsar\\"
target_dir = "G:\\pulsar\\"

shutil.copytree(source_dir,target_dir)
