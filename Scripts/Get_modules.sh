#!/bin/bash
python3 -m venv ../Py/tiki_api_venv
REQUIREMENTS_FILE="../Py/requirements.txt"
cd ../Py
source tiki_api_venv/bin/activate

echo -e "${YELLOW}Installing required packages...${RESET}"
if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
  echo -e "${RED}Error: $REQUIREMENTS_FILE not found!${RESET}"
  exit 1
fi

while IFS= read -r line; do
  if [[ -n "$line" && ! "$line" =~ ^# ]]; then
    echo -e "${YELLOW}Installing $line...${RESET}"
    pip install "$line"
  fi
done < "$REQUIREMENTS_FILE"

echo -e "${GREEN}All packages installed successfully.${RESET}"

deactivate

cd ../Scripts