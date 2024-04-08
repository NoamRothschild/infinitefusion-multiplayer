import requests
import time
import os
from pathlib import Path

def get_server_url():
    file = open('server_site.txt', 'r')
    return file.read()

def get_client_num():
    other_player = ""
    client_num = input("What Player Are You Connecting As? [1/2]")
    match client_num:
        case "1":
            other_player = "client2"
        case "2":
            other_player = "client1"
        case _:
            print("Error while fetching player number, please type again.")
            get_client_num()
    client_num = f"client{client_num}"
    return client_num, other_player

def gift_pokemon(other_player):
    name = f"gift_poke{other_player}"
    if os.path.exists(name):
        file = {'file': open(name, 'rb')}
        requests.post(url, files=file)
    os.remove(name)


#NEED TO BE RAN FROM EACH PLAYER CONNECTING TO THE SERVER
def get_secondary_client_from_server():
    return requests.get(f'{url}{second_client}').text.strip()

def set_secondary_client_location(new_location):
    file = open(f'{second_client}/client.rb', 'w')
    file.write(new_location)
    

#upload to server
def send_updated_loc():
    file = {'file': open(f"{client_num}/client.rb", 'rb')}
    requests.post(url, files=file)

def main():
    try:
        #while True:
        if True:
            time.sleep(.05)
            start = time.time()

            send_updated_loc()
            timestamp1 = round(time.time(), 2)
            print(f"{round(float(timestamp1-start), 2)} seconds for send_updated_loc()")

            secondary_c = get_secondary_client_from_server()
            timestamp2 = time.time()
            print(f"{round(float(timestamp2-timestamp1), 2)} seconds for get_secondary_client_from_server()")

            set_secondary_client_location(secondary_c) #giving the function the hash of the second player location from the server
            timestamp3 = time.time()
            print(f"{round(float(timestamp3-timestamp2), 2)} seconds for set_secondary_client_location()")

            print(f"\nTotal Time: {round(float(timestamp3-start), 2)}")

            #gift_pokemon() #constantly check for any exported pokemon, and if there is will send to server
    except KeyboardInterrupt:
        pass

if __name__ == '__main__':
    client_num, second_client = get_client_num()
    #url = "http://10.0.0.24:5000/" #get_server_url()
    #url = "https://23a5-2a06-c701-989f-9800-282a-d154-8922-15bf.ngrok-free.app/"
    url = "https://frosted120.pythonanywhere.com/"
    main()

#CLIENT 1