import json 
import psycopg2
import time
from Config import load_config

directory = input()
schema = input()
functions = input()
failed_indices = input()

def read_sql_file(file_name):
    with open(file_name, "r") as f:
        command = f.read()
    return command

def create_tables():
    command = read_sql_file(schema)
    try:
        config = load_config()
        with psycopg2.connect(**config) as conn:
            with conn.cursor() as cur:
                cur.execute(command)
    except (psycopg2.DatabaseError, Exception) as error:
        print("Database error:", error)

def create_functions():
    command = read_sql_file(functions())
    try:
        config = load_config()
        with psycopg2.connect(**config) as conn:
            with conn.cursor() as cur:
                cur.execute(command)
    except (psycopg2.DatabaseError, Exception) as error:
        print("Database error:", error)

def load_into():
    with open(failed_indices, "w") as f:
        f.write("")
        
    insert_product = """
    SELECT insert_product(%s, %s, %s, %s, %s);
"""
    insert_product_image = """
    SELECT insert_product_image(%s, %s, %s, %s, %s, %s, %s, %s);
"""
    try:
        config = load_config()
        conn = psycopg2.connect(**config)
        cur = conn.cursor()
    except (psycopg2.DatabaseError, Exception) as error:
        print("Database error:", error)
        return 
    cur.execute('alter sequence product_images_image_id_seq restart with 1;')
    cur.execute('delete from product_images')
    cur.execute('delete from products')
    conn.commit()
    for i in range(200000):
        file_name = f"{directory}/file_{i+1}.json"
        with open(file_name, "r") as f:
            data = json.load(f)
        if(len(data) == 0):
            pass 
        else:
            try:
                cur.execute(insert_product, (
                    data['id'],
                    data['name'],
                    data['url_key'],
                    data['price'],
                    data['description']
                ))
                if data['images'] is not None:
                    for image in data['images']:
                        cur.execute(insert_product_image, (
                            data['id'],
                            image['base_url'],
                            image['large_url'],
                            image['medium_url'],
                            image['small_url'],
                            image['thumbnail_url'],
                            image['is_gallery'],
                            image['label'] if image['label'] is not None else None
                        ))
                conn.commit()
            except Exception as e:
                with open(failed_indices, "a") as f:
                    f.write(f"file_{i+1}.json")
                print(e)
                conn.rollback()
    conn.close()
    cur.close()

start = time.time()
create_tables()
create_functions()
load_into()
print(f"Execution time: {time.time()-start}(s)")