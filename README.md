# Bellabeat Marketing Analysis

**Background**: It is the second case study of Google Data Analytics Professional certificate program. Bellabeat is a high-tech  manufacturer of health-focused products for women. The case study requires the analyst to follow the steps of data analysis process: ask, prepare, process, analyze, share, and act by using Fitbit Fitness Tracker users data. 

**Business Task**: To unlock the new growth opportuities by analyzing the smart device data and gain insights into how consumers are using their smart devices to prepare high-level marketing strategy for the company.

**Ask**: To conduct this analysis, I have to examine What are some trends in smart device usage? How could these trends apply to Bellabeat customers? How could these trends help influence Bellabeat marketing strategy?

**Prepare**: FitBit Fitness Tracker Data (CC0: Public Domain, dataset made available through Mobius). This Kaggle data set contains personal fitness tracker from thirty fitbit users. Thirty eligible Fitbit users consented to the submission of personal tracker data, including minute-level output for physical activity, heart rate, and sleep monitoring. It includes information about daily activity, steps, and heart rate that can be used to explore users’ habits. The data set is stored in 13 different .csv format and contains data about:
Calories
Intensities
Total Steps
Sleeping Hours
Daily Activity
Heartrate
Weight

To perform analysis, I focused on the following files:

dailyActivity_merged.csv: It contains information about the activity date, total steps, total distance, sedentary active distance, and calories. It contains 940 observation of 15 variables of 33 different users.

sleepDay_merged.csv: It contains information about the sleep day, total sleep records, total minutes asleep and total time in bed. It contains 413 observations of  5 variables of different users. 

weightLogInfo_merged.csv: It contains information about weight logs of different users in Kg and Pounds, as well as the Body Mass Index (BMI), a measure of the body corpulence based on the height and weight of the person. It has 67 observations of  8 variables. It has only information about 8 users, which do not represent the overall population, so I did not use it for the analysis.

minuteMETsNarrow_merged.csv: It contains information about minute measures of the METs of 33 different users. Basically, METs means Metabolic Equivalents, and they are a way to measure the intensity of activity. 1 MET is the amount of energy you use when you are still. So, an activity of 3 METS is an activity in which you are spending 3 times the amount of energy you would spend staying still. The intensity of activities are classified as follows (according to healthline):

Light activity: < 3 mets
Moderate activity: 3 - 6 mets
Vigorous activity: > 6 mets

It contains 1325580 obs. of  3 variables.


heartrate_seconds_merged.csv: It contains information about the heart rate of different users, which is measured each 5 seconds and contains 2483658 obs. of  3 variables.

In terms of limitations, there is no data provided on age and gender of the users as Bellabeat's target audience is female users.

**Process**: I used R for data cleaning, manipulation and visualization. 
Firstly, I loaded the necessary packages and set my working directory:
install.packages("tidyverse")
library(tidyverse)
library(lubridate)
library(janitor)
library(ggplot2)
setwd("~/Downloads/Bellabeat_datset/Fitabase Data 4.12.16-5.12.16/dataset_for_analysis")

Then, I imported the different tables of the dat set for analysis:
daily_activity <- read.csv("dailyActivity_merged.csv")
daily_sleep <- read.csv("sleepDay_merged.csv")
weight <- read.csv("weightLogInfo_merged.csv")
METs_minute <- read.csv("minuteMETsNarrow_merged.csv")
heartrate_seconds <- read.csv("heartrate_seconds_merged.csv")

By using str() function, I checked the structure of the tables
str(daily_activity)
str(daily_sleep)
str(weight)
str(METs_minute)
str(heartrate_seconds)

Checking data for NA values:
sum(is.na(daily_activity))
sum(is.na(daily_sleep))
sum(is.na(weight))
sum(is.na(METs_minute))
sum(is.na(heartrate_seconds))

Dataframe related to weight  is missing 65 values. To look closely, I used summary() function on weight dataframe:
summary(weight)

All of the missing values are in the Fat column of dataframe. Column is missing 65 observations out of 67 total obs. I can not find the values for this column, so I delete the entire column by setting it to NULL:
weight$Fat <- NULL

By checking the structure of data sets I find out that all the time values are in character data type, so I converted it into date() and parse date time():
daily_activity$ActivityDate <- as.Date(daily_activity$ActivityDate, format = "%m/%d/%Y")

heartrate_seconds <- heartrate_seconds %>%  
  mutate(Time = mdy_hms(Time))

METs_minute <- METs_minute %>% 
  mutate(ActivityMinute = mdy_hms(ActivityMinute))

daily_sleep$SleepDay <- as.Date(daily_sleep$SleepDay, format = "%m/%d/%Y")

weight$Date <- as.Date(weight$Date, format = "%m/%d/%Y")

The data recorded by Fitbit smart device does not record the decimal point for METs value in Mets_minute data set. So, I divide the values by 10 to get the conversion for METs values by using mutate() function:
METs_minute <- mutate(METs_minute, METs = METs / 10)

As the Id column is presented in all the data sets, which will allow me to merge the data sets together but before merging I have to check how many participants data is avaliable in different dataframes. By using n_distinct() function, I will check if they repeat on the other dataframes:
n_distinct(daily_activity$Id)
unique(daily_activity$Id)

I have 33 unique values in the Id column of daily_activity data set. To count those unique values in other data set by using unique() func:
sum(unique(daily_activity$Id) %in% unique(heartrate_seconds$Id))
sum(unique(daily_activity$Id) %in% unique(daily_sleep$Id))
sum(unique(daily_activity$Id) %in% unique(METs_minute$Id))
sum(unique(daily_activity$Id) %in% unique(weight$Id))

As, data set from METs table contains 33 unique values so i will merge it with daily_activity data set. Since, the weight data set contains only 8 unique values. I will not use the data set for analysis. Sleep data set contains 24 unique values. I will use this for analysis, but by creating a separate data frame than above one.

In order to merge daily_activity and Mets_minute data set, I rename the info of METs_minute ActivityMinute column into date column and transform METs_minute info into daily_mets:
METs_minute <- mutate(METs_minute, date = date(ActivityMinute))
daily_mets <- aggregate(METs~Id + date, METs_minute, FUN = sum)

After that, I change the name of the date field in the daily_activity table and then I merge the data set by using "Id" and "date" column:
daily_activity <- rename(daily_activity, date = ActivityDate)
daily_activity <- merge(daily_activity, daily_mets, by = c("Id", "date"))

Since, the daily_sleep data set contains 24 unique Id values, I merge it with daily_activity table in different data set. To do this, I modify the name of the date column in the daily_sleep table and then merge both the data sets:
daily_sleep <- rename(daily_sleep, date = SleepDay)
daily_activity_sleep <- merge(daily_activity, daily_sleep, by = c("Id", "date"))

After preparing the data sets, I save them by using write.csv() function:
write.csv(daily_activity, "bellabeat_analysis.csv")
write.csv(daily_activity_sleep,"bellabeat_analysis2.csv")
