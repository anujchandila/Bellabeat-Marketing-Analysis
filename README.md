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

**Process**: I used R for data cleaning, manipulation and visualization. I imported the different tables of the dat set for analysis:
daily_activity <- read.csv("dailyActivity_merged.csv")
daily_sleep <- read.csv("sleepDay_merged.csv")
weight <- read.csv("weightLogInfo_merged.csv")
METs_minute <- read.csv("minuteMETsNarrow_merged.csv")
heartrate_seconds <- read.csv("heartrate_seconds_merged.csv")

By using str() function, I checked the structure of the tables


