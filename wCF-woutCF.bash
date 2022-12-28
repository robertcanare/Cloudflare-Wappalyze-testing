#!/bin/bash

# Test Wappalyzer to each domains with CF and without CF protection

# Please update this name of the file
url_file=$2

# Output file name
output_filename=$1
rm -rf $output_filename
touch $output_filename

# Cleare the hosts file
echo "" > /etc/hosts

# AWKed files
urls=$(cat $url_file | awk '{ print $1 }')

for url in $urls; do
        # Check the domain NS if it is in Cloudflare
        cloudflare_check=$(dig $url NS | grep "cloudflare")
        if [ -z "$cloudflare_check" ]
                then
                        # Not in Cloudflare domains testing
                        tech_wout_CF=$(node /app/wappalyzer/src/drivers/npm/cli.js https://$url | jq '.technologies[].name' | sed -e 's/^"//' -e 's/"$//' | tr '\n' ' ' )
                        echo "$url" "," "NOT IN CF" "," "$tech_wout_CF"  >> $output_filename
                else
                        # In Cloudflare domains testing
                        tech_w_CF=$(node /app/wappalyzer/src/drivers/npm/cli.js https://$url | jq '.technologies[].name' | sed -e 's/^"//' -e 's/"$//' | tr '\n' ' ' )

                        # Bypassing CF testing part
                        # Adding the IP on host file
                        ip=$(grep $url $url_file | awk '{ print $2 }')
                        echo "$ip $url" >> /etc/hosts
                        sleep 10
                        tech_wout_CF=$(node /app/wappalyzer/src/drivers/npm/cli.js https://$url | jq '.technologies[].name' | sed -e 's/^"//' -e 's/"$//' | tr '\n' ' ' )
                        echo "$url" "," "$tech_w_CF" "," "$tech_wout_CF" >> $output_filename

        fi
done
