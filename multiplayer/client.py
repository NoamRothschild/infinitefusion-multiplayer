import requests
import time

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
    while True:
        time.sleep(.1)
        send_updated_loc()
        secondary_c = get_secondary_client_from_server()
        set_secondary_client_location(secondary_c) #giving the function the hash of the second player location from the server

if __name__ == '__main__':
    client_num, second_client = get_client_num()
    url = "http://10.0.0.24:5000/" #get_server_url()
    main()