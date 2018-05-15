#This script will create playbook base on json file entries
import json
import os
routerValue = False;
hostFile = "hosts"
string1=""
fname = raw_input('Enter file name: ')
if ( len(fname) < 1 ) : fname = 'ansible_host_data.json'
if os.path.exists(hostFile) : os.remove(hostFile)
str_data = open(fname).read()
json_data = json.loads(str_data)

for entry in json_data:
    ip_address = entry[0]
    user_name = entry[1]
    password = entry[2]
    device_model = entry[3]
    device_type = entry[4]
    string1 = device_model+ " ansible_connection=local ansible_ssh_host= "+ip_address+" user="+user_name+" passwd= "+password+"\n"
    with open(hostFile,"a+") as fhost:
        fhost.write(string1)
with open(hostFile,"a+") as fhost:
    fhost.write("\n\n\n[router]\n")
for entry in json_data:
    device_type = entry[4]
    device_model = entry[3]
    if device_type=="router":
        with open(hostFile,"a+") as fhost:
            fhost.write(device_model+"\n")

with open(hostFile,"a+") as fhost:
    fhost.write("\n\n\n[switch]\n")
for entry in json_data:
    device_type = entry[4]
    device_model = entry[3]
    if device_type=="switch":
        with open(hostFile,"a+") as fhost:
            fhost.write(device_model+"\n")
