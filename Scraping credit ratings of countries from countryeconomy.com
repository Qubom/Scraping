# Importing necessary libraries & modules

import requests
from bs4 import BeautifulSoup
from time import sleep
import random
import csv

# Choosing url we'd like to start from

url = 'https://countryeconomy.com/ratings'
# setting user-agent to be seen more human-like by server (not necessary)
headers = {'user-agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36'}
# getting our url in text form
req = requests.get(url, headers=headers)
src = req.text

# transforming our text in beautifulsoup object

soup = BeautifulSoup(src, 'lxml')

# getting all the links we are going to enter and scrape from

all_countries = soup.find("tbody").find_all("a")

# collecting all the links into python list

all_links_list = []
for link in all_countries:
    #link_text = link.text.split(" [")[0]
    link_href = "https://countryeconomy.com" + link.get("href")
    all_links_list.append(
        link_href
    )
    
# printing all the links just to check if everything's going fine

print(all_links_list)

# starting to write our csv file

with open("Credit ratings by country.csv", "a", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(("Country", "Date", "Rating"))

# setting counter to be aware of the progress of scraping

count = 0

# scraping data about credit rating changes
# information about country name and rows containing rating and date of change

for country in all_links_list:
    q = requests.get(country).content
    soup = BeautifulSoup(q, 'lxml')
    country_name = soup.find("h1").find("span").text[8:-14] # to select only country name from the string
    long_rating = soup.find("tbody").find_all("tr")
# take some break not to disturb the server
    sleep(random.randrange(3, 5))
# updating our counter and printing the progress
    count += 1
    print(f'#{count}: {country_name} is scraped!')
# getting date of change and rating itself
    for item in long_rating:
        date = item.find("td").text
        rating = item.find_all("td")[1].text
        # writing date and rating into our csv file
        with open("Credit ratings by country1.csv", "a", newline = '') as file:
            writer = csv.writer(file)
            writer.writerow((country_name, date, rating))
