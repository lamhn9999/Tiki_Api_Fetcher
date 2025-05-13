import json
import time
import pandas

directory_in = input()
directory_out = input()
product_csv = input()
pending_indices = input() 
pending_429s = input()
isNothing = "../Data/isNothing.txt"
isOk = "../Data/isOk.txt"

df = pandas.read_csv(product_csv)

need = {"id", "name", "url_key", "price", "images", "description"}
sum429 = 0
sumNON = 0
sumOK = 0

with open(pending_indices, "r") as f:
    ids = [int(id) for id in f]
with open(pending_429s, "w") as f:
    f.write("") #empty file
with open(pending_indices, "w") as f:
    f.write("") #empty file
    
config_429 = open(pending_429s, "a")
f_429 = open(pending_indices, "a")
f_NON = open(isNothing, "a")
f_OK = open(isOk, "a")

def proceed(data, file_out):
    global need
    global sumNON
    global sumOK 
    cnt = 0
    with open(file_out, "w") as f:
        f.write("{")
        for key, item in data.items():
            if key in need:
                cnt += 1
                f.write(json.dumps({key:item}, separators =(",", ":")).strip("{}"))
                if cnt < 6: 
                    f.write(",")
        f.write("}")
    if cnt == 6:
        f_OK.write(file_out + '\n')
        sumOK += 1
    elif cnt == 0:
        f_NON.write(file_out + '\n')
        sumNON += 1

def main():
    global sum429
    global df
    global ids
    for i in ids:
        file_in = directory_in + "/file_" + str(i) + ".json"
        try:
            with open(file_in, "r") as f:
                data = json.load(f)
                proceed(data, directory_out + "/file_" + str(i) + ".json")
        except:
            config_429.write("url = \"https://api.tiki.vn/product-detail/api/v1/products/" + str(df['id'][i-1]) + "\"" + "\n" + "output = " + directory_in + "/file_" + str(i) + ".json\n")
            f_429.write(str(i) + '\n')
            sum429 += 1

start_time = time.time()
main()
print(f"429 error: {sum429}\nProduct not found: {sumNON}\nProduct found: {sumOK}")
print(f"Execution time: {time.time() - start_time}")

config_429.close()
f_429.close()
f_NON.close()
f_OK.close()
