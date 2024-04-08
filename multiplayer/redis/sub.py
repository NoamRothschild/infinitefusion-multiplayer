import redis
import os
import time
import re

redis_client = redis.StrictRedis(host='redis-14396.c72.eu-west-1-2.ec2.cloud.redislabs.com',port=14396,password='8x3y3Sjy8YJXqO2NMmv2xEG4Q11JBd3H')
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

def update_map(curr_channel, new_channel):
    pubsub.subscribe(new_channel)
    pubsub.unsubscribe(curr_channel)

if __name__ == '__main__':
    for message in pubsub.listen():
        if message['type'] == 'message':
            decoded_msg = message['data'].decode('utf-8')
            match = re.search(r":player_num=>(\d+)", decoded_msg) #Get player num
            recieved_player_num = match.group(1)
            print(f"Found new location for {recieved_player_num}: {decoded_msg}")

            if recieved_player_num != player_num:
                with open(f"{os.getcwd()}/../client{player_num}/client.rb", 'w') as file:
                    file.write(decoded_msg)
                    print(f"Saved new location for {recieved_player_num}")
                


