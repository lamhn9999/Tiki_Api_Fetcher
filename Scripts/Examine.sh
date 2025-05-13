#!/bin/bash

directory_data="../Data"
directory_out="$directory_data/Product_details_done"
total_ids=200000

source ../Py/tiki_api_venv/bin/activate
echo "Choose an option:"
echo "1. Examine a product description"
echo "2. Check for duplicates"
echo -n "q. Quit"
while true; do
    echo -e "\n--------------------------------------------"
    read -p "Enter your choice (1, 2, or q): " choice

    case "$choice" in
        1)
        read -p "Enter a file number (1 to 200000): " num
        file="$directory_out/file_${num}.json"

        if [[ -f "$file" ]]; then
            echo -e "\nDescription from $file:"
            jq -r '.description' "$file"
        else
            echo "File $file does not exist."
        fi
        ;;
        2)
        echo "Running Check_duplicates.py..."
        echo -e "$directory_out\n$total_ids" | python3 ../Py/Check_duplicates.py
        ;;
        q|Q)
        echo "Exiting. Goodbye!"
        break
        ;;
        *)
        echo "Invalid option. Please enter 1, 2, or q."
        ;;
    esac
done
