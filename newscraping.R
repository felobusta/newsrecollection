
# webscraping chilean (digital) media outlets -----------------------------------------
#load packages

library(rvest)
library(tidyverse)
library(topicmodels)
library(tm)
library(stringr)
library(ldatuning)
library(rlist)
library(stm)

#create links to download links of each news -----------------------------------------------
#go to the media outlet from wbere you want to get the data and see if their search bar gives you results per page or on a slide manner
#if its per page you also have to check that going to the next page doesn't involves the use of some javascript in the page that doesn't change the URL
#for example, https://www.latercera.com/etiqueta/coronavirus/ gives you pages and each time you change to the next one you get a new URL
#but https://www.emol.com/tag/coronavirus/1566/todas.aspx makes a query without changing the page. For the first case we use R and for the second case we
#use python to download the links (check the other repo to get that code)

#after checking we can see that  https://www.latercera.com/etiqueta/coronavirus/ has 667 pages, so 667 links where we have to get the other links

#create each link of the 667 https://www.latercera.com/etiqueta/coronavirus/page/

page<- (1:667)

urls <- list()

for (i in 1:length(page)) { 
  url<- paste0("https://www.latercera.com/etiqueta/coronavirus/page/",page[i])
  urls[[i]] <- url
}

length(urls)

alfa<- list()

for (j in seq_along(urls)) {
  
  alfa[[j]]<- urls[[j]]%>%
    session()%>%
    html_nodes(xpath = "/html/body/div/div/div/main/section/div/article/div/div/h3/a")%>%
    html_attr('href')
    
#we add a print to get the nomber of each page in case there is some error (404 error) or problem with our connection

  print(j)
}

#the way /html/body/div/div/div/main/section/div/article/div/div/h3/a works in https://www.latercera.com/etiqueta/coronavirus/page/
#gives you only part of the URL, so we have to create the rest:
# incomplete links, create full link ------------------------------------------

todas <- as.list(paste0("https://www.latercera.com",unlist(alfa)))
length(todas) #check how many links you get
class(todas) #just to be sure lets check if it created a list 
toda.news <- unlist(todas) #"todas" is a list that contains list so create an list with all the links
View(toda.news)
length(toda.news)

#because we only get a couple of thousands links we will save them in an excel
library(xlsx)

write.xlsx(toda.news, 'linksLaTercera.xlsx')

# download headline, date and body of the articles ---------------------------------------

library(readxl)

linksLaTercera <- read_excel("LINKS/linksLaTercera.xlsx")

toda.news<-linksLaTercera$x

length(todas2)

class(toda.news)

todas2<-as.list(toda.news)

#lest make a small test (30 links) and check if our code is working

todas.test <- todas2[1:30]

pruebaTercera <- list()

before doing the scraping we need to understand what's the HTML code of each part of the article. So go to one or two links and use inspect on chrome and clic
#on each part and copy the full xpath.
#For example, in La Tercera these are the parts for headlines, date, and body of the article:
#headline
#/html/body/div/div/section/article/header/div/div/h1/div
#date
#/html/body/div/div/section/article/header/div/div/div/time
#body of article
#/html/body/div/div/section/article/div/div/div/div/div/p

for (j in seq_along(todas2)) {
  pruebaTercera[[j]] <- todas2[[j]] %>% 
    session() %>% 
    html_nodes(xpath = "/html/body/div/div/section/article/header/div/div/h1/div|
                     /html/body/div/div/section/article/header/div/div/div/time|
             /html/body/div/div/section/article/div/div/div/div/div/p") %>%
    html_text()
#again, we use print to see if there are any 404 errors or issues with our connection and to see how many links R has checked
  print(j)
}

pruebaTercera

#after this we have a big list (30 lists) with other lists inside 
#because of how the website is desing we know that each list has these characteristicas
#list[[i]][1] #contains the headline
#list[[i]][2] #contains the date
#and from list[[i]][3] till the last value of n (list[[i]][n]) it #contains the body of the article. 
#so we want to pass this to a dataframe to work on it on a tidy manner or just to create an excel

# from list to dataframe -------------------------------------------------
#create lists with new objects for each part of the article
fecha      <- list()
titular    <- list()
nueva      <- list()
split.news <- list()

for (i in seq_along(pruebaTercera)) {
  i <- i
  titular[[i]]    <- pruebaTercera[[i]][1] #get headline
  fecha[[i]]      <- pruebaTercera[[i]][2] #get date
  nueva[[i]]      <- paste(pruebaTercera[[i]], collapse = '/') #collapse the full content of the list into one list
  split.news[[i]] <- str_split(nueva, "/", n = 3)[[i]][3] #from the collapsed content we will separate it into 3 parts and get the last one (the full body)
}

#finally create the dataframe

cbind(as.data.frame(unlist(titular)), 
                          as.data.frame(unlist(fecha)), 
                          as.data.frame(unlist(split.news)))%>%
  mutate(titular = as.character(unlist(titular)),
         fecha   = as.character(unlist(fecha)),
         cuerpo = as.character(unlist(split.news)))%>%
  select(titular, 
         fecha, 
         cuerpo) -> latercera.test
         
#also, lets add a new column with the links we used

latercera.test$link <- unlist(todas.test)
 
 
