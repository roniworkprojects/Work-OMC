from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import openpyxl
import re

chromedriver_path = r"C:\Program Files\Google\Chrome\Application\chromedriver.exe"
username = "username"
password = "password"
url = f"http://{username}:{password}@URL.COM/DIR/DIR/navbarsearch=1&host=*&limit=3000&service=nsca_check_hostcpu2&servicestatustypes=28"

try:
    chrome_service = ChromeService(chromedriver_path)
    driver = webdriver.Chrome(service=chrome_service)

    driver.get(url)

    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CLASS_NAME, "status"))
    )

    alert_table = driver.find_element(By.CLASS_NAME, "status")
    rows = alert_table.find_elements(By.TAG_NAME, "tr")[1:]

    infra_workbook = openpyxl.Workbook()
    infra_sheet = infra_workbook.active
    infra_sheet.title = "Infra Alerts"

    cloud_workbook = openpyxl.Workbook()
    cloud_sheet = cloud_workbook.active
    cloud_sheet.title = "Cloud Alerts"
    last_host_name = ""  # Initialize last_host_name outside the loop
    for i, row in enumerate(rows):
        if i >= 24:  # Skip the first 24 rows (indexing starts from 0)
            data = row.text.split()
            if len(data) >= 3:  # Check if there are at least 3 elements
                host_name = data[0]
                check_name = data[1]


                if re.match(r'^(nsca|check)', host_name):  # Check if the host_name starts with 'nsca' or 'check'
                    state = data[1]
                    check_name = data[0]
                    host_name = last_host_name
                    alert_time = data[3] + " " + data[4]
                    prob_time = " ".join(data[5:9])
                    remaining_data = " ".join(data[9:])
                else:
                    last_host_name = host_name
                    state = data[2]
                    alert_time = data[3] + " " + data[4]
                    prob_time = " ".join(data[5:9])
                    remaining_data = " ".join(data[9:])

                if re.match(r'^\d', host_name):  # Cloud alert if host starts with a digit
                    cloud_sheet.append([host_name, check_name, state, alert_time, prob_time, remaining_data])
                else:  # Infra alert
                    infra_sheet.append([host_name, check_name, state, alert_time, prob_time, remaining_data])
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    if 'driver' in locals():
        driver.quit()

    infra_workbook.save("Infra_Alerts.xlsx")
    cloud_workbook.save("Cloud_Alerts.xlsx")
