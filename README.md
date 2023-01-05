
## newsrecollection

This is some code I used to collect covid related news for two articles/papers. It may be a bit long, but it does the job. In this case, we only have two examples, one for latercera.cl (only R code) and one for emol.cl (Python and R code), but you can use it for any other news media outlet that lets you get the xpaths from the HTML code, like elpais.es, or theclinic.cl.

There are two important aspects to consider: 

- R code: may work even on paywalls
- Python code: when there is a pop up there could be some issues, so you must check the website and its structure before running the code

## Packages used

```{r, eval = FALSE}
#webscraping chilean (digital) media outlets -----------------------------------------
#load packages
install.packages("rvest")
install.packages("tidyverse")

library(rvest)
library(tidyverse)
```

## Create links to download links of each news -----------------------------------------------
The first thing is to visit the media outlet website from where you want to get the data and see if their search bar gives you results per page or on a slide manner. If its per page you also have to check that going to the next page doesn't involve the use of some javascript that doesn't change the URL, as rvest requires the URL. For example, https://www.latercera.com/etiqueta/coronavirus/ gives you pages and each time you change to the next one you get a new URL, but https://www.emol.com/tag/coronavirus/1566/todas.aspx makes a query without changing the page. For the first case we use R and for the second case we use python to download the links of each article and later R to download the contect of each article (check the other repo to get that code).

There is some information we must understand before running some code related to HTML code. Basically, each website is made of some HTML code, just like some rmarkdowns documents. So when we visit a website each part is defined by HTML code and an xpath, this last part is the one rvest and Python use to identify the content in the site. You can visit this site to get more information about HTML code and xpaths: https://html.com/.


```{r, eval = FALSE}
#After checking we can see that  https://www.latercera.com/etiqueta/coronavirus/ has 667 pages, so 667 links where we have to get the other links.
#So, we create each link of the 667, from  https://www.latercera.com/etiqueta/coronavirus/page/1 until page/667

page<- (1:667)

urls <- list()

for (i in 1:length(page)) { 
  url<- paste0("https://www.latercera.com/etiqueta/coronavirus/page/",page[i])
  urls[[i]] <- url
}

#after creating the links we have to download each article link
length(urls)
alfa<- list()

for (j in seq_along(urls)) {
  
  alfa[[j]]<- urls[[j]]%>%
    session()%>%
#you can check the xpath by inspecting the webpage in chrome or any web browser you are using
    html_nodes(xpath = "/html/body/div/div/div/main/section/div/article/div/div/h3/a")%>%
    html_attr('href')   
#we add a print to get the number of each page in case there is some error (404 error) or problem with our connection
  print(j)
}

#the way /html/body/div/div/div/main/section/div/article/div/div/h3/a works in https://www.latercera.com/etiqueta/coronavirus/page/
#gives you the URL without the "https://www.latercera.com" part, so we have to create the rest:
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
```


