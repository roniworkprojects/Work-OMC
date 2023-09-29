import requests
import json

# Defining the api-endpoint
url = 'https://api.abuseipdb.com/api/v2/check'
ip_list = ["191.96.249.183", "31.96.249.183"]
querystring = {
    'ipAddress': '191.96.249.183',
    'maxAgeInDays': '90'
}
headers = {
    'Accept': 'application/json',
    'Key': 'ENTER_API_KEY'
}
for i in ip_list:
    querystring['ipAddress'] = i
    response = requests.request(method='GET', url=url, headers=headers, params=querystring)

    # Formatted output
    decodedResponse = json.loads(response.text)
    abuse_score = decodedResponse["data"]["abuseConfidenceScore"]
    response = requests.get(f"https://ipinfo.io/{querystring['ipAddress']}/json")
    country = response.json()["country"]

    if abuse_score > 0 or country != "IL":
        print(querystring['ipAddress'])


