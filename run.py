#!/usr/bin/env python

import os
import io
import json

CONFIG_FILE="/config/ServerConfig.json"

def env_or_default(var,default):
  if var in os.environ:
    return os.environ[var]
  else:
    return default

def python_dict_to_json_file(d, file_path):
    with io.open(file_path, 'w', newline='\r\n', encoding="utf-8") as outfile:
        outfile.write(unicode(json.dumps(d, indent=2, sort_keys=True, ensure_ascii=False)))

    print(file_path + " created. ")

def python_json_file_to_dict(file_path):
    print "Looking for " + file_path
    try:
        # Get a file object with write permission.
        file_object = open(file_path, 'r')
        # Load JSON file data to a python dict object.
        dict_object = json.load(file_object)

        return dict_object
    except Exception as e:
        print "Exception:"
        print type(e)
        print e
        print(file_path + " not found. ")
    except ValueError as e:
        print "Could not decode JSON from " + file_path
    return {}

####################################################################################

API_KEY=env_or_default("API_KEY", None)
PROXY_URL=env_or_default("PROXY_URL", None)
PROXY_PORT=env_or_default("PROXY_PORT", None)
PROXY_TYPE=env_or_default("PROXY_TYPE", None)

DEFAULTS_DICT = {
  "Port": 9117,
  "AllowExternal": True,
  "APIKey": None,
  "AdminPassword": None,
  "InstanceId": "",
  "BlackholeDir": None,
  "UpdateDisabled": False,
  "UpdatePrerelease": False,
  "BasePathOverride": None,
  "OmdbApiKey": None,
  "OmdbApiUrl": None,
  "ProxyUrl": None,
  "ProxyType": 0,
  "ProxyPort": None,
  "ProxyUsername": None,
  "ProxyPassword": None,
  "ProxyIsAnonymous": True
}

if os.path.exists(CONFIG_FILE):
  # If config file is found, inject the api key
  print "Config file exists"
  CONFIG_DICT = python_json_file_to_dict(CONFIG_FILE)
else:
  print "Config file does not exist"
  # If config file is not found, create it with defaults hash
  CONFIG_DICT = DEFAULTS_DICT

print "Writing to config file"

CONFIG_DICT["APIKey"] = API_KEY
CONFIG_DICT["ProxyUrl"] = PROXY_URL
CONFIG_DICT["ProxyPort"] = PROXY_PORT
CONFIG_DICT["ProxyType"] = PROXY_TYPE

python_dict_to_json_file(CONFIG_DICT, CONFIG_FILE)

with open('/config/api_key.txt', 'w') as f:
  f.write(CONFIG_DICT["APIKey"])

os.execv("/usr/bin/mono", ("/usr/bin/mono", "/Jackett/JackettConsole.exe", "-d", "/config"))
