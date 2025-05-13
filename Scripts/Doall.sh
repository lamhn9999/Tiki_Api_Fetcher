#!/bin/bash

chmod u+x Get_modules.sh
chmod u+x Clean.sh
chmod u+x Get.sh
chmod u+x Transform.sh
chmod u+x Ini_database.sh
chmod u+x Load.sh
chmod u+x Examine.sh

RED='\e[31m'
ORANGE='\e[38;5;208m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
RESET='\e[0m'
export RED ORANGE GREEN YELLOW BLUE MAGENTA CYAN RESET

directory_data=../Data
directory_in="$directory_data/Product_details_pending"
directory_out="$directory_data/Product_details_done"
directory_backup="$directory_data/Product_details_backup"
product_ids_csv="$directory_data/Product_ids.csv"
total_ids=200000
export directory_data directory_in directory_out directory_backup product_ids_csv total_ids

pending_ids="$directory_data/Pending_ids.txt"
pending_indices="$directory_data/Pending_indices.txt"
pending_429s="$directory_data/List_urls_retry_429.txt"
isOk="$directory_data/isOk.txt"
isNothing="$directory_data/isNothing.txt"
list_urls="$directory_data/list_urls.txt"
export pending_ids pending_indices pending_429s isOk isNothing list_urls

./Get_modules.sh
source ../Py/tiki_api_venv/bin/activate

./Clean.sh
./Get.sh
./Transform.sh
./Load.sh

deactivate
