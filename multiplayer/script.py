import os
import glob
import time

def search_for_trainer(directory):
    for file_path in glob.iglob(os.path.join(directory, '**/*.rb'), recursive=True):
        read_script(file_path)


def read_script(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            #if "$Trainer" in content and "head" in content and "body" in content:
            wanted_text = "dependentEvents"
            if wanted_text in content and "PokemonGlobal" in content:
                cut_path = file_path[45:]
                print(f"{cut_path} contains {wanted_text}")
            #print("inside file? ", content)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")

def open_path(path):
    try:
        with open(path, "r", encoding='utf-8') as f:
            content = f.read()
            print(content)
        f.close()
    except Exception as e:
        print(e)



open_path("\\\\NOAMRTD\\multiplayer\\Client.json")
time.sleep(5)
#search_for_trainer('D:\\Program-Files\\InfiniteFusion\\Data\\Scripts') #SHOULD NOT BE COMMENT WHEN WORKING

#read_script("D:\\Program-Files\\InfiniteFusion\\Data\\Scripts\\999_Main\\998_showdown.rb")
