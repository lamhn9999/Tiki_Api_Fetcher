#!/bin/bash

echo -e "${RED}Cleaning up un-processed product details before moving on...${RESET}"

if [[ ! -d $directory_in ]]; then 
    echo -e "${GREEN}All clear!${RESET}"
    exit
fi
if [[ ! -d $directory_out ]]; then 
    echo -e "${GREEN}All clear!${RESET}"
    exit
fi

Categorizing_Extracting_Retrying() {
    while true; do
        find "$directory_in" -type f -name "file_*.json" -printf "%f\n" | cut -c 3- | awk -F'[_.]' '{print $2}' | sort -g > $pending_indices
        echo -e "$directory_in\n$directory_out\n$product_ids_csv\n$pending_indices\n$pending_429s" | python3 ../Py/Categorize_and_Extract.py;

        find $directory_in -name "*.json" -delete

        is_429=$(wc -l < $pending_429s)
        if [ $is_429 -eq 0 ]; then break; fi;
        echo -e "${YELLOW}Re-downloading $(( is_429 / 2 )) product details due to 429 error...${RESET}"
        curl --parallel --parallel-immediate --parallel-max 50 --config $pending_429s -S;
    done
}

Categorizing_Extracting_Retrying
echo -e "${GREEN}All clear!${RESET}"