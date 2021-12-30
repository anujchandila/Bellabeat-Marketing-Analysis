install.packages("tidyverse")
library(tidyverse)
library(lubridate)
library(janitor)
library(ggplot2)
setwd("~/Downloads/Bellabeat_datset/Fitabase Data 4.12.16-5.12.16/dataset_for_analysis")

daily_activity <- read.csv("dailyActivity_merged.csv")
daily_sleep <- read.csv("sleepDay_merged.csv")
weight <- read.csv("weightLogInfo_merged.csv")
METs_minute <- read.csv("minuteMETsNarrow_merged.csv")
heartrate_seconds <- read.csv("heartrate_seconds_merged.csv")

str(daily_activity)
str(daily_sleep)
str(weight)
str(METs_minute)
str(heartrate_seconds)

sum(is.na(daily_activity))
sum(is.na(daily_sleep))
sum(is.na(weight))
sum(is.na(METs_minute))
sum(is.na(heartrate_seconds))

summary(weight)
weight$Fat <- NULL


daily_activity$ActivityDate <- as.Date(daily_activity$ActivityDate, format = "%m/%d/%Y")

heartrate_seconds <- heartrate_seconds %>%  
  mutate(Time = mdy_hms(Time))

METs_minute <- METs_minute %>% 
  mutate(ActivityMinute = mdy_hms(ActivityMinute))

daily_sleep$SleepDay <- as.Date(daily_sleep$SleepDay, format = "%m/%d/%Y")

weight$Date <- as.Date(weight$Date, format = "%m/%d/%Y")
 
METs_minute <- mutate(METs_minute, METs = METs / 10)

str(daily_activity)
str(daily_sleep)
str(weight)
str(METs_minute)
str(heartrate_seconds)

n_distinct(daily_activity$Id)
unique(daily_activity$Id)

sum(unique(daily_activity$Id) %in% unique(heartrate_seconds$Id))
sum(unique(daily_activity$Id) %in% unique(daily_sleep$Id))
sum(unique(daily_activity$Id) %in% unique(METs_minute$Id))
sum(unique(daily_activity$Id) %in% unique(weight$Id))


METs_minute <- mutate(METs_minute, date = date(ActivityMinute))

str(METs_minute)

daily_mets <- aggregate(METs~Id + date, METs_minute, FUN = sum)

str(daily_mets)

daily_activity <- rename(daily_activity, date = ActivityDate)

str(daily_activity)

daily_activity <- merge(daily_activity, daily_mets, by = c("Id", "date"))

str(daily_sleep)
daily_sleep <- rename(daily_sleep, date = SleepDay)

daily_activity_sleep <- merge(daily_activity, daily_sleep, by = c("Id", "date"))
str(daily_activity_sleep)

write.csv(daily_activity, "bellabeat_analysis.csv")

write.csv(daily_activity_sleep,"bellabeat_analysis2.csv")

ggplot(data = daily_activity, aes(x= Calories)) +
  geom_smooth(mapping = aes(y = TotalDistance), color = 'orange') +
  geom_smooth(mapping = aes(y = TotalSteps / 1000), color = 'purple') +
  scale_y_continuous(name = "Total distance",
                     sec.axis = sec_axis(~.*1000, name = "Number of steps")) +
  labs(title = "Distance vs Calories vs Total Steps")  

ggplot(data = daily_activity) +
  geom_point(mapping = aes(x = TotalSteps, y = SedentaryMinutes), color = "darkorange")+
  geom_smooth(mapping = aes(x = TotalSteps, y= SedentaryMinutes), color = "darkgreen") +
  labs(title = "Sedentary Time vs Total Steps",
       x= "Total Number of Steps",
       y = "Sedentary Minutes")

ggplot(data = daily_activity, aes(x= METs, y= Calories)) +
  geom_point(color = "red") +
  geom_smooth(color = "blue")+
  labs(title = "Calories vs METs")

ggplot(daily_activity_sleep, aes(x = TotalMinutesAsleep, y = SedentaryMinutes))+
  geom_point()+
  geom_smooth(color = 'blue')+
  labs(title = "Sedentary Minutes vs Sleeping Time",
       x = "Sleeping time (mins)",
       y = "Sedentary time (mins)") +
  theme_minimal()

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

METs_minute <- mutate(METs_minute, mets_hour = hour(ActivityMinute))

str(METs_minute)

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


