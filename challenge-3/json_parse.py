import json
import sys

json_str = sys.argv[1]
key = sys.argv[2]

json_obj = json.loads(json_str)

value = json_obj
for k in key.split("."):
    value = value[k]

print(value)
