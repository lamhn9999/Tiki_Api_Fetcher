#!/bin/bash

> $pending_ids
> $pending_indices
rm -rf $directory_in && mkdir -p $_ 
ids_arr=($(cat $product_ids_csv | tail -n +2)) # Extracting ids from csv file into an array

Generating_all_ids() {
    echo -e "${RED}Preparing to download all $total_ids product details...${RESET}"
    seq 1 $total_ids > $pending_indices
    for ((i=0; i<$total_ids; i++)); do
        echo ${ids_arr[i]} >> $pending_ids
    done
    echo -e "${GREEN}All set!${RESET}"
}

Generating_remaining_ids() {
    total_ids=$((total_ids - total_ids_exist + 2))
    echo -e "${RED}Preparing to download $total_ids remaining product details...${RESET}"
    for ((i = 1; i < total_ids_exist; i++)); do
        for ((j = existing_ids[i - 1] + 1; j < existing_ids[i]; j++)); do
            echo ${ids_arr[j-1]} >> $pending_ids
            echo $j >> $pending_indices
        done
    done
    echo -e "${GREEN}All set!${RESET}"
}

if [[ -d $directory_out ]]; then
    existing_ids=($(ls -1 $directory_out | awk -F'[_.]' '{print $2}' | sort -g -u | (echo 0; cat; echo $((total_ids + 1)))))
    total_ids_exist=${#existing_ids[@]} # 0 and total_ids + 1 are added to the list

    if [[ $((total_ids_exist-2)) -eq $total_ids ]]; then
        echo "All $total_ids product details have already been downloaded."
        read -p "To re-download, type 'Y'. To skip, press any other key: " key
        if [[ $key == "Y" ]]; then
            Generating_all_ids
        else
            echo -e "${MAGENTA}Download skipped.${RESET}"
            rm -f $pending_ids
            rm -f $pending_indices
            rm -rf $directory_in
            exit
        fi
    elif [[ $((total_ids_exist-2)) -ne 0 ]]; then
        echo "$((total_ids_exist-2)) product details have been downloaded."
        read -p "Type 'Y' to download only the remaining ones, 'N' to download all again, or anything else to skip: " key
        case $key in
            Y) Generating_remaining_ids ;;
            N) Generating_all_ids ;;
            *)
                echo -e "${MAGENTA}Download skipped.${RESET}"
                rm -f $pending_ids
                rm -f $pending_indices
                rm -rf $directory_in
                exit
                ;;
        esac
    else
        Generating_all_ids
    fi
else
    mkdir $directory_out
    Generating_all_ids
fi

echo "Make sure you want to start the download proccess!"
read -p "To start downloading, type 'Y'. To skip, type any other things: " key;
if [ $key != "Y" ]; then echo -e "${MAGENTA}Download skipped.${RESET}"; rm -f $pending_ids; rm -f $pending_indices; rm -r $directory_in; exit; fi
echo -e "${MAGENTA}Download commencing shortly.${RESET}"

# Everything happens inside Scripts/

lines_per_batch=$(( total_ids/5 ))
total_batches=5
Generating_batch() {
    local i=$1
    start=$((i * lines_per_batch + 1));
    if [[ $i -eq $((total_batches - 1)) ]]; then
        end=$total_ids
    else
        end=$((start + lines_per_batch - 1))
    fi
}

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

for (( batch=0; batch<total_batches; batch++ )); do
    Generating_batch $batch
    output="$directory_data/ids-$start-$end.txt"
    tail -n +$start $pending_ids | head -n $((end-start+1)) > $output
    output="$directory_data/indices-$start-$end.txt"
    tail -n +$start $pending_indices | head -n $((end-start+1)) > $output
done

echo -n "" > $isOk
echo -n "" > $isNothing
#case < 5??
for (( batch=0; batch<total_batches; batch++ )); do
    echo -e "${RED}Downloading Batch #$((batch + 1))...${RESET}"
    
    Generating_batch $batch
    list_ids="$directory_data/ids-$start-$end.txt";
    list_indices="$directory_data/indices-$start-$end.txt"

    paste $list_ids $list_indices | awk -v dir="$directory_in" '{printf("url = \"https://api.tiki.vn/product-detail/api/v1/products/%lld\"\noutput = %s/file_%lld.json\n", $1, dir, $2)}' > "$list_urls"
    
    cnt=$(ls -1 $directory_in | wc -l)

    while true; do
        curl --parallel --parallel-immediate --parallel-max 50 --config $list_urls -S
        if [ $(ls -1 $directory_in | wc -l) -eq $(($end - $start + 1 + cnt)) ]; then
            echo -e "${GREEN}Batch #$((batch + 1)): DOWNLOAD SUCCESSFUL${RESET}";
        break;
        else
            echo $(ls -1 $directory_in | wc -l)
            echo $(($end - $start + 1 + cnt))
            echo -e "${YELLOW}Batch #$((batch + 1)): DOWNLOAD UNSUCCESSFUL or INCOMPLETE${RESET}";
            echo -e "${YELLOW}Re-downloading Batch #$((batch + 1))${RESET}";
            sleep 0.2;
        fi
    done
    sleep 0.2;
    echo -e "${ORANGE}Categorizing downloaded product details into: {PRODUCTS FOUND, PRODUCTS NOT FOUND, PRODUCTS ENCOUNTERED 429 ERROR}, extracting necessary fields, and retrying unsuccessful downloads...${RESET}"
    Categorizing_Extracting_Retrying
    echo -e "${GREEN}Batch #$((batch + 1)): PRE-PROCESSING COMPLETE${RESET}";
done

# Going home
# rm -r $directory_in
rm $isOk $isNothing $pending_ids $pending_indices
rm *.txt