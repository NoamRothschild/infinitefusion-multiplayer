import requests
import time
from pathlib import Path

#url = "https://f94e-2a06-c701-988c-b900-c1fa-f4c5-2741-70c3.ngrok-free.app"
url = "http://10.0.0.24:5000"

file_path = Path.cwd() / "client1" / "client.rb"

#testing
#f = open(file_path, "r")
#contents = f.read()

#r = requests.get('https://1f25-2a06-c701-988c-b900-c1fa-f4c5-2741-70c3.ngrok-free.app/client1')

#print(f"response.text value:{r.text.strip()}")
#print("end of response value")
start = time.time()
files = {'file': open(file_path, 'rb')}
response = requests.post(url, files=files)
end = time.time()
print(end-start)
#print(f"response value: {response.text}, {response.url}")



#print(response.text)


