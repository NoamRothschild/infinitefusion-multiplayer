try:
    #This version is not map-dependent & server error note
    from os import chdir
    from os.path import dirname, abspath
    chdir(dirname(abspath(__file__)))

    with open('db-info.txt', 'r') as file:
        # Read the lines
        lines = file.readlines()

    # Initialize variables
    host = None
    port = None
    password = None

    # Iterate through each line
    for line in lines:
        # Split the line by '='
        key, value = line.strip().split('=')
        # Strip whitespace from the key and value
        key = key.strip()
        value = value.strip()
        
        # Assign values based on the key
        if key == 'host':
            host = value.replace("'", "")
        elif key == 'port':
            port = int(value)
        elif key == 'password':
            password = value.replace("'", "")

    import time

    if host == '' and port == 0 and password == '':
        raise Exception("Please add your redis database details to the file before starting")


    #From Here
    import redis
    import os
    import re
    import multiprocessing
    import sys
    redis_client = redis.StrictRedis(host=host,port=port,password=password)
    pubsub = redis_client.pubsub()

    class GlobalVariables:
        def __init__(self) -> None:
            self.player_num = int(open(f"{os.getcwd()}/../player_num.txt", 'r').read().strip())
            if self.player_num == 1:
                self.other = 2
            elif self.player_num == 2:
                self.other = 1
            else:
                print(f"Error Reading Player Number From player_num.txt\nMake sure you entered settings and configured player num correctly")
                time.sleep(5)
                sys.exit()

            self.others_map = re.search(r":map_id=>(\d+)", open(f"{os.getcwd()}/../client{f'{self.other}'}/client.rb", 'r').read().strip()).group(1)
            self.first_time: bool = True


    GlobalVars = GlobalVariables()

    file_path = f"{os.getcwd()}/../client{f'{GlobalVars.player_num}'}/client.rb"
    last_loc = open(file_path, 'r').read().strip()
    last_map = re.search(r":map_id=>(\d+)", last_loc).group(1)
    pubsub.subscribe('Location')
    pubsub.subscribe('Gift-Channel')

    def check_for_gift(_gift_file_path):
        raw = open(_gift_file_path, 'r').read().strip()
        if raw != '':
            #Found a gift package
            redis_client.publish('Gift-Channel', f"{GlobalVars.other}:{raw}")
            #[7:]
            print(f'detected gift for player{GlobalVars.other} containing: \n{raw}')

            with open(_gift_file_path, 'w') as f:
                print("Cleaning file...")
                f.write('')

    def listner():
        print("Entering Listner...")
        for message in pubsub.listen():
            if message['type'] == 'message':
                decoded_msg = message['data'].decode('utf-8')
                channel = message['channel'].decode('utf-8')
                #print(f"New message from channel {channel}")
                if channel == 'Gift-Channel':
                    if f"{decoded_msg}".strip().startswith(f"{GlobalVars.player_num}:"):
                        print("Found a gift for you!")
                        with open(os.path.join(os.getcwd(), '..', f'gift_poke{GlobalVars.player_num}.json'), 'w') as f:
                            print("Writing gift to file...")
                            f.write(decoded_msg[2:]) #Removes added text to only send needed info
                        continue
                    elif f"{decoded_msg}".startswith(f"{GlobalVars.other}:"):
                        print(f"Found a gift for {GlobalVars.other}")
                        continue
                    else:
                        print(f"Couldnt process gift, \nplease report this to the github repo if found. \nerror info: {decoded_msg}")
                        continue

                match = re.search(r":player_num=>(\d+)", decoded_msg) #Get player num
                recieved_player_num = match.group(1)
                if int(recieved_player_num) != GlobalVars.player_num:
                    with open(f"{os.getcwd()}/../client{recieved_player_num}/client.rb", 'w') as file:
                        file.write(decoded_msg)
                        print(f"Updated location for client{recieved_player_num}")
                    GlobalVars.others_map = re.search(r":map_id=>(\d+)", decoded_msg).group(1)

    if __name__ == '__main__':
        try:
            multiprocessing.freeze_support()
            listner_thread = multiprocessing.Process(target=listner)
            listner_thread.start()

            #Start listening for new updates in your map
            print("Sucessfully started up listner!")

            while True:
                if GlobalVars.first_time:
                    GlobalVars.first_time = False
                check_for_gift(f"{os.getcwd()}/../gift_poke{GlobalVars.other}.json")

                with open(file_path, 'r') as f:
                    curr_loc = f.read().strip()
                
                if curr_loc == '':
                    continue

                if curr_loc != last_loc:
                    print("Client Move Detected! (Your Client)")
                    #match = re.search(r":map_id=>(\d+)", curr_loc) #Get map id
                    #map_id = match.group(1)
                    #match_old = re.search(r":map_id=>(\d+)", last_loc) #Get old map id
                    #old_map_id = match_old.group(1)
                    #if old_map_id != map_id:
                    #    print("Moved into another map! -> switching channel...")
                    #    update_map(pubsub, old_map_id, map_id)
                    #    listner_thread.terminate()
                    #    listner_thread.join()
                    #    listner_thread = multiprocessing.Process(target=listner)
                    #    listner_thread.start()
                    print(f"Sent location in channel 'Location' with data {curr_loc}")
                    redis_client.publish('Location', curr_loc)
                    last_loc = curr_loc
        except KeyboardInterrupt:
            listner_thread.terminate()
            print("Stopped By User.")
        except Exception as e:
            print(f"An error has occured: {e}")
except Exception as e:
    input(f"An erorr has occured! Please report this error to the reddit post if struggling,\nError: {e}")