################################# USER GUIDE #################################
#
# After creating the database in redis, click on 'connect' and copy needed crodentials here:

host = ''
port = 0
password = '' 

# After you are done you can go ahead and save & close this file
#
################################# USER GUIDE #################################

import redis
import os
import re
import time
import multiprocessing
redis_client = redis.StrictRedis(host=host,port=port,password=password)
pubsub = redis_client.pubsub()


player_num = int(open(f"{os.getcwd()}/../player_num.txt", 'r').read().strip())
if player_num == 1:
    other = 2
elif player_num == 2:
    other = 1
else:
    print(f"Error Reading Player Number From player_num.txt")
    time.sleep(5)
    exit()

file_path = f"{os.getcwd()}/../client{player_num}/client.rb"
last_loc = open(file_path, 'r').read().strip()
last_map = re.search(r":map_id=>(\d+)", last_loc).group(1)
pubsub.subscribe(last_map)

def update_map(pubsub, curr_channel, new_channel):
    pubsub.subscribe(new_channel)
    pubsub.unsubscribe(curr_channel)

def listner():
    print("Entering Listner...")
    for message in pubsub.listen():
        if message['type'] == 'message':
            decoded_msg = message['data'].decode('utf-8')
            match = re.search(r":player_num=>(\d+)", decoded_msg) #Get player num
            recieved_player_num = match.group(1)
            print(f"Found new location for client{recieved_player_num}: {decoded_msg}")
            if int(recieved_player_num) != player_num:
                with open(f"{os.getcwd()}/../client{recieved_player_num}/client.rb", 'w') as file:
                    file.write(decoded_msg)
                    print(f"Saved new location for client{recieved_player_num}")


if __name__ == "__main__":
    try:
        multiprocessing.freeze_support()
        listner_thread = multiprocessing.Process(target=listner)
        listner_thread.start()
        #Start listening for new updates in your map
        while True:
            curr_loc = open(file_path, 'r').read().strip()
            if curr_loc != last_loc:
                print("Client Move Detected! (Your Client)")
                match = re.search(r":map_id=>(\d+)", curr_loc) #Get map id
                map_id = match.group(1)
                match_old = re.search(r":map_id=>(\d+)", last_loc) #Get old map id
                old_map_id = match_old.group(1)
                if old_map_id != map_id:
                    print("Moved into another map! -> switching channel...")
                    update_map(pubsub, old_map_id, map_id)
                    listner_thread.terminate()
                    listner_thread.join()
                    listner_thread = multiprocessing.Process(target=listner)
                    listner_thread.start()
                redis_client.publish(map_id, curr_loc)
                last_loc = curr_loc
    except KeyboardInterrupt:
        listner_thread.terminate()
        print("Stopped By User.")
    except Exception as e:
        print(f"An error has occured: {e}")
