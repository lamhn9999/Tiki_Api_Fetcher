import json 
import time
import pandas
from bs4 import BeautifulSoup

directory = input()
total_obj = int(input())
archive = input()
product_ids_csv = input()

df = pandas.read_csv(product_ids_csv)

def transform_field_description():
    global total_obj
    global directory
    global df
    start = time.time()

    archive = []
    for i in range(total_obj):
        file_name = directory + "/file_" + str(i+1) + ".json"
        
        with open(file_name, "r") as f:
            data = json.load(f)
        try:
            description = data['description']
        except:
            archive.append({'id' : int(df['id'][i]), 'number' : i+1, 'description' : None})
            continue 
        archive.append({'id' : data['id'], 'number' : i+1, 'description' : data['description']})

        soup = BeautifulSoup(description, "html.parser")
        data['description'] = ''.join(line for line in soup.get_text(separator='\n').splitlines(keepends=True) if line.strip())
        with open(file_name, "w") as f:
            json.dump(data, f)
    with open(archive, "w") as f:
        json.dump(archive, f, indent=4)
    print(f"Execution time: {time.time() - start} second(s)")
    
transform_field_description()