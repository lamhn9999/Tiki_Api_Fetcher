#!/bin/bash

schema="../Sql/Schema.sql"
functions="../Sql/Functions.sql"
failed_indices="../Sql/Failed_indices.txt"

echo -e "${YELLOW}Loading data into database...${RESET}"
./Ini_database.sh
echo -e "$directory_out\n$schema\n$functions\n$failed_indices" | python3 ../Py/Load.py

echo -e "${GREEN}Data is fully loaded!${RESET}"