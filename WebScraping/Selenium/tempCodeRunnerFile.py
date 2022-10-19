
## pip install selenium
from selenium import webdriver
driver = webdriver.Chrome()
driver.get("https://www.seleniumeasy.com/test/jquery-download-progress-bar-demo.html")
## loading the page will take some time, so ask the driver to wit for some time
driver.implicitly_wait(10)  ## wait for 10 sec before doing anyhting

## element = driver.find_element_by_id('downloadButton')
## element.click()
