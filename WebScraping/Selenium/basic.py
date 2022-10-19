
## pip install selenium
from selenium import webdriver
driver = webdriver.Chrome()
driver.get("https://www.seleniumeasy.com/test/jquery-download-progress-bar-demo.html")
## loading the page will take some time, so ask the driver to wit for some time

driver.implicitly_wait(10)  ## wait for 10 sec before doing anyhting
## if the page and all the things is loaded correclt, then no need to wait
## it wont wait for the given time then

## once this time is set, it will be deafult take the implicit time before finding
## the elements in the script

element = driver.find_element('id','downloadButton')
element.click()
