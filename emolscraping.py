#This is the code to download the article links from https://www.emol.com/tag/coronavirus/1566/todas.aspx
#because https://www.emol.com/tag/coronavirus/1566/todas.aspx doesn't create a new URL when we click next we 
#have to use a bot to scroll the webpage, download the article links and only then he can click on the "next"

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
import time
import pandas

#we will use Firefox, but it should also work on chrome and explorer
driver = webdriver.Firefox()
#give the link
driver.get("https://www.emol.com/tag/coronavirus/1566/todas.aspx")
#we have to give the bot a couple of seconds so he can load the full page
time.sleep(3)

#we need the bot to scroll until the end of the page
#scrolling
lenOfPage = driver.execute_script("window.scrollTo(0, document.body.scrollHeight);var lenOfPage=document.body.scrollHeight;return lenOfPage;")
match=False
while(match==False):
    lastCount = lenOfPage
    time.sleep(3)
    lenOfPage = driver.execute_script("window.scrollTo(0, document.body.scrollHeight);var lenOfPage=document.body.scrollHeight;return lenOfPage;")
    if lastCount==lenOfPage:
        match=True

#again, we make him wait for a couple of seconds
#wait
WebDriverWait(driver, 20)

#driver.find_element_by_xpath("/html/body/div[1]/div/div[2]/div/div/div[1]/span").click()

#create empty list for the links
posts = []

#create function to get the links and after getting the links to click
def foo():
   
    links2 = driver.find_elements_by_xpath("/html/body/div/div/div/div/div/div/ul/li/div/a")
    for link in links2:
        post = link.get_attribute("href")
        posts.append( post )    
    driver.find_element_by_class_name("txt_siguiente").click()
    time.sleep(20)
    foo()
   
foo()

#this last part should be in another .py file, just don't run it until the bot has visited all the other links
news2 = pandas.DataFrame(posts)
len(news2)
news2.to_csv('Emol_agosto.csv')
