import json
import os

directory = input()
total_ids = int(input())

def get_json_ids(directory, total_ids):
    list_ids = []
    for i in range(1, total_ids + 1):
        file_name = os.path.join(directory, f"file_{i}.json")
        try:
            with open(file_name, "r") as f:
                data = json.load(f)
            list_ids.append(data['id'])
        except FileNotFoundError:
            continue
        except json.JSONDecodeError:
            print(f"Invalid JSON in: {file_name}")
        except KeyError:
            continue
        except Exception as e:
            print(f"Error reading {file_name}: {e}")
    print(f"Number of ids found: {len(list_ids)}")
    return list_ids

def check_duplicates(lst):
    if len(lst) != len(set(lst)):
        print("The list has duplicates.")
    else:
        print("The list does not have duplicates.")

check_duplicates(get_json_ids(directory, total_ids))
