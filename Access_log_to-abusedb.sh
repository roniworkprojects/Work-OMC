#!/bin/bash


# Define the API endpoint
url="https://api.abuseipdb.com/api/v2/check"
api_key="ENTER_API_KEY"

# Replace 'access.log' with the path to your access log file
log_file="/path/to/your/access.log"

# Use 'tail' to get the last 100 lines from the log file
log_entries=$(tail -n 100 "$log_file")

# Use 'grep' and 'awk' to extract the IP addresses from the log entries
ip_addresses=($(echo "$log_entries" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $1}'))

# Check if IP addresses were found
if [ ${#ip_addresses[@]} -gt 0 ]; then
  echo "Last 100 IP addresses found:"
  for ip in "${ip_addresses[@]}"; do
    querystring="ipAddress=$ip&maxAgeInDays=90"

    # Make the API request using curl
    response=$(curl -s -H "Accept: application/json" -H "Key: $api_key" "$url?$querystring")

    # Extract abuse score using jq
    abuse_score=$(echo "$response" | jq -r '.data.abuseConfidenceScore')

    # Get country information using curl and jq
    country=$(curl -s "https://ipinfo.io/$ip/json" | jq -r '.country')

    # Check conditions and print IP address
    if [ "$abuse_score" -gt 0 ] || [ "$country" != "IL" ]; then
        echo "$ip"
    fi
done
    


    
