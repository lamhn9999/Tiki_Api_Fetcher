#!/bin/bash

archive="$directory_data/Product_descriptions_archive.json"

echo "Make sure you want to start the transformation proccess!"
read -p "To start transforming, type 'Y'. To skip, type any other things: " key;
if [ $key != "Y" ]; then echo -e "${MAGENTA}Transformation skipped.${RESET}"; exit; fi

read -p "Create a backup directory? Type 'Y' to proceed. Type 'N' to remove existing backup directory. Type any other things to skip. " key
if [[ $key == "Y" ]]; then 
	if [ ! -d $directory_backup ]; then
	    mkdir $directory_backup
       	    cp -r $directory_out $directory_backup
	    echo -e "${GREEN}Backup directory created.${RESET}"
	else 
	    echo -e "${GREEN}There has already been a backup directory.${RESET}"
	fi
elif [[ $key == "N" ]]; then
	rm -rf $directory_backup
	echo -e "${GREEN}Backup directory removed.${RESET}"
else
	echo -e "${MAGENTA}Backup step skipped.${RESET}"
fi

echo -e "${RED}Transforming data...${RESET}"
echo -e "$directory_out\n200000\n$archive\n$product_ids_csv" | python3 ../Py/Transform.py;
echo -e "${GREEN}Transformation done!${RESET}"
