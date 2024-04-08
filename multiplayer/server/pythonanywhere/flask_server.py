from flask import Flask, request, redirect, url_for
from werkzeug.utils import secure_filename
import os
import re

#FOLDER_CLIENT_1 = 'D:\\Program-Files\\InfusionCopies\\MultiplayerProject\\infinitefusion-multiplayer\\multiplayer\\server\\client1'
#FOLDER_CLIENT_2 = 'D:\\Program-Files\\InfusionCopies\\MultiplayerProject\\infinitefusion-multiplayer\\multiplayer\\server\\client2'
ALLOWED_EXTENSIONS = {'txt', 'zip', 'json', 'png', 'jpg', 'rb'}

app = Flask(__name__)
#app.config['FOLDER_CLIENT_1'] = FOLDER_CLIENT_1
#app.config['FOLDER_CLIENT_2'] = FOLDER_CLIENT_2

player_info = {'client1': 'UNASSIGNED',
               'client2': 'UNASSIGNED'}


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        
        file = request.files['file']
        filename = secure_filename(file.filename)
        file_contents = file.read().decode('utf-8')
        pattern = r":player_num=>(\d+)"
        match = re.search(pattern, file_contents)
        if match:
            player_number = int(match.group(1))
        else:
            print("there was an error with the uploaded file...")

        #player_info['client2'] = f"{file_contents}"
        
        #if 1==2:
        if player_number == 1:
            #file2 = open(os.path.join(app.config['FOLDER_CLIENT_1'], "client.rb"), 'w')
            #file2.write(file_contents)
            #file.close()
            player_info['client1'] = file_contents
        elif player_number == 2:
            #file2 = open(os.path.join(app.config['FOLDER_CLIENT_2'], "client.rb"), 'w')
            #file2.write(file_contents)
            #file.close()
            player_info['client2'] = file_contents
        else:
            print("unable to load player number succesfully...")
                
        
    return '''
    <!doctype html>
    <h1>Clean HTML, to see more go into url/client1 or url/client2</h1>
    '''

@app.route('/client1')
def client1():
    #file = open(f"{FOLDER_CLIENT_1}\\client.rb", 'r')
    #data = file.read()
    data = player_info['client1']
    return f'''{data}'''

@app.route('/client2')
def client2():
    #file = open(f"{FOLDER_CLIENT_2}\\client.rb", 'r')
    #data = file.read()
    data = player_info['client2']
    return f'''{data}'''


#python3 -m http.server 5000

if __name__ == '__main__':
    app.run(host='0.0.0.0', port= 5000 ,debug=True)
