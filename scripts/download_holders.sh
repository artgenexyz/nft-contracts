#!/bin/sh

export NFT="0xF6DF9657282Bac986B0e40BDD2889AA95cae156b"
export API_KEY="jxmoIBCGsS1lG9yKgkFNr7uyuj81O5Y07Y3tdBoL33ObbV7ZfL4mYwMDuvswQLPx"
# export OFFSET = 0
# export URL = "https://deep-index.moralis.io/api/v2/nft/$NFT/owners?chain=eth&format=decimal&offset=$OFFSET"

# clean eap_holders.csv
rm eap_holders.csv
touch eap_holders.csv

# bash loop from 0 to 7000 step 500
for i in $(seq 0 500 7000); do
    export OFFSET=$i
    export URL="https://deep-index.moralis.io/api/v2/nft/$NFT/owners?chain=eth&format=decimal&offset=$OFFSET"
    export FILENAME="eap_holders_page_$i.json"

    echo "Loading page $i, saving to $FILENAME..."

    curl -X 'GET' $URL -H 'accept: application/json' -H "X-API-Key: $API_KEY" | jq > $FILENAME
    cat "$FILENAME" | jq 'del(.result)'
    cat "$FILENAME" | jq --raw-output '.result[] .owner_of' >> eap_holders.csv

    # delay 500 ms
    echo "Sleeping for 500 ms..."
    sleep 0.5
done


# print the number of holders
echo "Done! Loaded $i pages."
echo "Number of holders: $(cat eap_holders.csv | wc -l)"



