import shutil, os
import time

#We'll wait 15 sec to make sure everything is up and running...
time.sleep(15)
target_dir = "C:\\pulsar\\files\\staging\\"

for the_file in os.listdir(target_dir):
    file_path = os.path.join(target_dir, the_file)
    try:
        if os.path.isfile(file_path):
            os.unlink(file_path)
        elif os.path.isdir(file_path): shutil.rmtree(file_path)
    except Exception as e:
        print(e)
