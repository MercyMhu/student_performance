
##################################################################################################
# Machine Learning Capstone Project
# From https://www.kaggle.com/code/danielebdon/capstone-using-ml-to-predict-student-performance

# Using Dev Ansodariya's Student Performance Dataset, I plan to develop and train a linear regression model to predict students' 
# grades based on features such as previous grades, health, father and mother occupation/education, etc.
# 
# The goal of this project is to provide insights into how these factors contribute to students' 
# grades and to help educators or students make data-driven decisions to improve performance.

##################################################################################################

rm(list=ls())
setwd("/home/mhurum@moe.govt.nz/Capstone")
library(tools)
library(tidyverse)  #by loading this library I will not need to load tidyr, dplyr, ggplot, readr, stringr etc
library(caret) #classification and regression
library(randomForest) #classification and regression
library(e1071)  # miscellaneous functions in statistics and probability
library(rpart) # recursive partitioning anf regression trees
library(rpart.plot)  # enhanced version of rpart
library(xgboost) #extreme gradient boosting
library(shiny) #web application framework for R


color_scale <- c("#ED7D31", "#FFC000", "#6EE32D", "#70AD47", "#51C398", "#4472C4", "#1F497D")
primary_colours <- c("#FF6D1E", "#FF4A0E", "#BD3804")
secondary_colours <- c("#000000", "#522953", "#641D2E", "#A62F42",
                                "#FFBD51", "#FFEFD5", "#F5F5F5", "#A6A6A6")

#Data downloaded from https://www.kaggle.com/datasets/devansodariya/student-performance-data

#call in the uploaded data into R
#new_dataframe <- source_data(options)
student_data20 <- read.csv("~/Capstone/student_data.csv")
student_data20$studentID <- seq_len(nrow(student_data20))

#Move studentID to be the very first column in the data
student_data20 <-student_data20[, c("studentID", setdiff(names(student_data20), "studentID"))]

head(student_data20)  #df.head
str(student_data20) 
dim(student_data20)  #df.shape
colnames(student_data20) #df.columns
summary(student_data20) #df.dtypes ut with less details

unique$study

# Step 1 : Data Prep
# colnames(student_data) <- str_to_title(colnames(student_data)) and colnames(student_data) <- stringr::str_to_title(colnames(student_data)) are similar
# Use the first by calling stringr package to use multiple functions within this package, use option 2 to just call a function from a package once.

colnames(student_data20) <- str_to_title(colnames(student_data20))
student_data20 <- student_data20 %>%
  rename(HomeLoc = Address) %>%
  select(-Guardian, -Reason, -Romantic, -Paid, -Nursery, -Goout, -Higher)  %>%
  distinct()

#filter(!duplicated(student_data)) 

#colSums(is.na(student_data)) #returns the count of NA values in each column

duplicates <- student_data20[duplicated(student_data20), ]
student_data20[duplicated(student_data20), ]  #checks for duplicated rows. If there are any, then student_data <- student_data[!duplicated(student_data), ]

student_data20$TotalGrade <- student_data20$G1 + student_data20$G2 + student_data20$G3
student_data20$AvgGrade <- round((student_data20$TotalGrade/3),2)

#Number of students by age
ggplot(student_data20, aes(x = Age)) +
  geom_bar(fill = primary_colours[3], color = primary_colours[3]) +
  labs(title = "Number of students by Age", 
       x="Age",
       y="Count of students") +
  theme_minimal()

#Distribution of study hours - study hours is a categorial variable (check by unique(student_data$Studytime)) so use bar chart
ggplot(student_data20, aes(x = Studytime)) +
  geom_bar(fill = primary_colours[1], color = primary_colours[1]) +
  labs( 
       x="Study hours",
       y="Count of students") +
  theme_minimal()

#check
# age_summary <- student_data20 %>%
#   group_by(Studytime)%>%
#   summarise(student_count=n(), .groups="drop")
# 
# ggplot(student_data20, aes(x = Freetime)) +
#   geom_bar(fill = primary_colours[1], color = primary_colours[1]) +
#   labs( 
#     x="Free time",
#     y="Count of students") +
#   theme_minimal()


#Distribution of average grade

names(student_data20)
unique(student_data20$AvgGrade)
n <- 395
bin_n <- ceiling(log2(n)+1)
ggplot(student_data20, aes(x = AvgGrade)) +
  geom_histogram(binwidth=2, fill=primary_colours[1], color = primary_colours[3]) +
  labs(title = "Distribution of average grade", 
       x="Average grade",
       y="Frequency") +
  theme_minimal()

#Scatterplot of age vs studytime

age_studytime <- student_data20 %>%
  group_by(Age, Studytime) %>%
  summarise(count_student=n(), .groups="drop")

ggplot(student_data20, aes(x = Age, y=Studytime)) +
  geom_jitter(width=0.2, height=0, color = primary_colours[2], alpha=0.7) +
  labs(title = "Age and Studytime",
       x= "Age (Years)",
       y="Study time in hours") +
  theme_minimal()


#scatterplot of 
 #G3 vs Studytime - does study time affect final grades 
 #G3 vs G1/G2 - do earlier grades predict future grades
 #G3 vs Absences - does more absences lead to lower grade

avg_G3 <- student_data20 %>%
  group_by(Studytime) %>%
  summarise(avg_G3 = mean(G3, na.rm=TRUE))

ggplot(student_data20, aes(x = as.factor(Studytime), y=G3)) +
  geom_jitter(width=0.2, height=0, color = primary_colours[2], alpha=0.7) +
  geom_crossbar(data=avg_G3, 
               aes(x=as.factor(Studytime),  
                   y=avg_G3, ymin=avg_G3, ymax=avg_G3),
               color=secondary_colours[1], linewidth=0.5, width=0.4) +
  geom_text(data=avg_G3,
            aes(x=as.factor(Studytime), y=avg_G3,
               label = sprintf("%.1f", avg_G3)),
               vjust=-1, hjust=-0.9, color=secondary_colours[1], size=4) +
  labs(title = "Final Grade and Studytime",
        x= "study time (categories)",
        y="Final Grade (G3)") +
  theme_minimal()


















