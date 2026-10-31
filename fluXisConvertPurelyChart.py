#im not commenting this fuck you lmao
import tempfile
import zipfile
import os
import json
import sys
import shutil

# Conversion happens here.
list1 = []
ToConvert = input("Chart Data:\n")
ParsedToConvert = json.loads(ToConvert)
hitobjectlist = ParsedToConvert.get("HitObjects")
for hitobject in hitobjectlist:
    time = hitobject.get('time')
    lane = hitobject.get('lane')
    type = hitobject.get('type')
    rawhitsound = hitobject.get('hitsound')
    hitsound = rawhitsound.strip(":")
    hidden = hitobject.get('hidden')
    final = str(time)+":"+str(lane)+":"+str(type)+":"+str(hitsound)
    list1.append(final)
list2 = ""
for string in list1:
    list2 = list2+string+"|"
keycount = input("Keycount: ")
foldername = input("Folder name: ")
try:
    metadata = ParsedToConvert.get("metadata")
    coverfile = ParsedToConvert.get("CoverFile")
    with open(os.path.dirname(os.path.abspath(sys.argv[0]))+"\\Songs\\"+foldername+"\\chart.hdc", "w") as f:
        cc = f.write(list2)
        print("Data has been written to chart file successfully\nTotal of ",cc," characters written.")
    meta = metadata.get('title') + ":" + coverfile + ":" + str(ParsedToConvert.get("TimingPoints")[0].get("bpm")) + ":" + str(metadata.get('previewtime') / 1000) + ":" + metadata.get("AudioFile") + ":" + metadata.get("artist") + ":" + metadata.get("mapper") + ":0:"+str(keycount)
    with open(os.path.dirname(os.path.abspath(sys.argv[0]))+"\\Songs\\"+foldername+"\\meta.txt", "w") as f:
        cc = f.write(meta)
        print("Data has been written to metadata file successfully\nTotal of ",cc," characters written.")
except FileExistsError:
    print(f"Directory '{foldername}' already exists.")
except PermissionError:
    print(f"Permission denied: Unable to create '{foldername}'.")
except Exception as e:
    print(f"An error occurred: {e}")