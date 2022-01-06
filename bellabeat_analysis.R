# Setting up the R environment by loading necessary packages
## set working directory
install.packages("tidyverse")
library(tidyverse)
library(lubridate)
library(janitor)
library(ggplot2)
setwd("~/Downloads/Bellabeat_datset/Fitabase Data 4.12.16-5.12.16/dataset_for_analysis")

# Process Phase
## Imported the data set for data cleaning
daily_activity <- read.csv("dailyActivity_merged.csv")
daily_sleep <- read.csv("sleepDay_merged.csv")
weight <- read.csv("weightLogInfo_merged.csv")
METs_minute <- read.csv("minuteMETsNarrow_merged.csv")
heartrate_seconds <- read.csv("heartrate_seconds_merged.csv")

## Let's look first the strcuture of tables using str() func
str(daily_activity)
str(daily_sleep)
str(weight)
str(METs_minute)
str(heartrate_seconds)

## Let's check dataframes for any NA values 
sum(is.na(daily_activity))
sum(is.na(daily_sleep))
sum(is.na(weight))
sum(is.na(METs_minute))
sum(is.na(heartrate_seconds))

## By checking dataframes for NA values, we found out that in weight data set column Fat contains 65 missing values out of total 67 observations
## To look into it more closely let's use summary() function
summary(weight)
## Since, I can not find the values for the Fat column
## So I decide to delete the entire column
weight$Fat <- NULL

## The structure of time date values are in character data type
## Let's convert it into date format 
daily_activity$ActivityDate <- as.Date(daily_activity$ActivityDate, format = "%m/%d/%Y")

heartrate_seconds <- heartrate_seconds %>%  
  mutate(Time = mdy_hms(Time))

METs_minute <- METs_minute %>% 
  mutate(ActivityMinute = mdy_hms(ActivityMinute))

daily_sleep$SleepDay <- as.Date(daily_sleep$SleepDay, format = "%m/%d/%Y")

weight$Date <- as.Date(weight$Date, format = "%m/%d/%Y")

## METs means Metabolic Equivalent and they are the way to measure the intensity of activity 
## Data recorded by the smart device does not record the decimal point for METs value
## Let's divide the values by 10 to correct it
METs_minute <- mutate(METs_minute, METs = METs / 10)

## Double check the structure of dataframes for the above changes
str(daily_activity)
str(daily_sleep)
str(weight)
str(METs_minute)
str(heartrate_seconds)

## As all the dataframes contains Id column, which would allow me to merge the dataframe into one
## Before merging the datasets let's check how many participants are in the dataframes by using n_distinct() function
n_distinct(daily_activity$Id)
unique(daily_activity$Id)

## There are 33 unique values on the Id column in daily_activity table
## Now let's check the unique values in other dataframes
sum(unique(daily_activity$Id) %in% unique(heartrate_seconds$Id))
sum(unique(daily_activity$Id) %in% unique(daily_sleep$Id))
sum(unique(daily_activity$Id) %in% unique(METs_minute$Id))
sum(unique(daily_activity$Id) %in% unique(weight$Id))

## By checking the unique values, we found out that the dataframes for heartrate and weight missing observation for almost half of the unique values
## So, I decided not to use them in analysis
## Since, daily_activity and METs_minute are the only dataframes with the same Id values so we can merge them
## In order to do that, first we need to change the name of the date field and transform the METs_minute data into daily info
METs_minute <- mutate(METs_minute, date = date(ActivityMinute))

str(METs_minute)

daily_mets <- aggregate(METs~Id + date, METs_minute, FUN = sum)

str(daily_mets)

## Now, we change the name of the ActivityDate column into date in daily_activity dataframe
## So, we can merge the dataframe by using the Id and date values
daily_activity <- rename(daily_activity, date = ActivityDate)

str(daily_activity)

daily_activity <- merge(daily_activity, daily_mets, by = c("Id", "date"))


str(daily_sleep)
## Since we have 24 Id values in daily_sleep dataframe common with daily_activity data
## I merge them in different dataframe name as daily_activity_sleep data set
## Let's rename the SleepDay column into date column and then merge them
daily_sleep <- rename(daily_sleep, date = SleepDay)

daily_activity_sleep <- merge(daily_activity, daily_sleep, by = c("Id", "date"))
str(daily_activity_sleep)

## Saving .csv files for further analysis in other tools 
write.csv(daily_activity, "bellabeat_analysis.csv")

write.csv(daily_activity_sleep,"bellabeat_analysis2.csv")

# Analysis Phase

## First, let's check for Distance vs Calories vs Total Steps
ggplot(data = daily_activity, aes(x= Calories)) +
  geom_smooth(mapping = aes(y = TotalDistance), color = 'orange') +
  geom_smooth(mapping = aes(y = TotalSteps / 1000), color = 'purple') +
  scale_y_continuous(name = "Total distance",
                     sec.axis = sec_axis(~.*1000, name = "Number of steps")) +
  labs(title = "Distance vs Calories vs Total Steps")  
## There is a positive correlation between all the three variables
## We can see the Total distance and the number of steps and calories burned on x-axis

## Total Steps vs Sedentary Minutes
ggplot(data = daily_activity) +
  geom_point(mapping = aes(x = TotalSteps, y = SedentaryMinutes), color = "darkorange")+
  geom_smooth(mapping = aes(x = TotalSteps, y= SedentaryMinutes), color = "darkgreen") +
  labs(title = "Sedentary Time vs Total Steps",
       x= "Total Number of Steps",
       y = "Sedentary Minutes")
## Here, we can see that we do not have any direct correlation between these two variables

## METs vs Calories
ggplot(data = daily_activity, aes(x= METs, y= Calories)) +
  geom_point(color = "red") +
  geom_smooth(color = "blue")+
  labs(title = "Calories vs METs")
## As we can see we have a positive correlation between these two variables 
## More the intensity of the activity more calories are burned

## Sleeping Time vs Sedentary Minutes
ggplot(daily_activity_sleep, aes(x = TotalMinutesAsleep, y = SedentaryMinutes))+
  geom_point()+
  geom_smooth(color = 'blue')+
  labs(title = "Sedentary Minutes vs Sleeping Time",
       x = "Sleeping time (mins)",
       y = "Sedentary time (mins)") +
  theme_minimal()

## We can see there is a negative correlation but the values under 300 minutes asleep is surprising
## To dig deeper into them let's check the summary by using summary() function
## A histogram and box plot are made to understand how the observations are distributed

daily_activity_sleep %>% 
  select(TotalMinutesAsleep) %>% 
  summary()

ggplot(data = daily_activity_sleep) +
  aes(x = TotalMinutesAsleep)+
  geom_histogram(fill = 'brown')+
  theme_minimal()+
  labs(title = 'Histogram of minutes asleep',
       x = 'Minutes Asleep')

ggplot(daily_activity_sleep) +
  aes(x = "", y = TotalMinutesAsleep) +
  geom_boxplot(fill = "#FF9999") +
  theme_minimal() +
  labs(title = "Box plot of Minutes Asleep",
       x = "",
       y = "Minutes Asleep") +
  annotate("text",
           x = 0.7, y = 200, label = "Even 200 minutes asleep are \nnot considered as outliers.",
           size = 4)

## I found out that the average sleeping time is 419 minutes which is about 7 hours of good sleep
## But the first quartile is at 361 minutes which are below 6 hours and not enough sleeping time 
## Several dots in the plot reveals that there is less than 200 minutes of sleep which is not at all healthy 
## This reveals people who are having sleep problems may be a bad habits that might produce insomnia
## This is important revelation that Bellabeat can use in the marketing strategy camapaign


## METs Distribution
## To look how METs distribute along the day when people are more active
## For doing this, first I create a new field with mets_hour
METs_minute <- mutate(METs_minute, mets_hour = hour(ActivityMinute))

str(METs_minute)

## In the new dataframe I group the means per hour of the METs
METs_min <- METs_minute %>% 
  group_by(mets_hour) %>% 
  summarise(mean_mets = mean(METs))

str(METs_min)

ggplot(data = METs_min, aes(x = mets_hour, y = mean_mets))+
  geom_bar(stat = "identity", fill = "brown")+
  labs(title = "Average METs distribution along the day",
       x = "Time of the day",
       y = "Average METs")+
  theme_minimal()
## Here, we can see that people are more active during day routine
## There are 2 peaks of activity: First one is at noon, and the second one is at 6pm



