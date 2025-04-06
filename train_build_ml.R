rm(list=ls())
setwd("/home/mhurum@moe.govt.nz/Capstone")
library(tools)
library(tidyverse)  #by loading this library I will not need to load tidyr, dplyr, ggplot, readr, stringr etc
library(caret) #classification and regression
library(ggplot2)
library(Metrics)
# library(randomForest) #classification and regression
library(e1071)  # miscellaneous functions in statistics and probability
library(rpart) # recursive partitioning anf regression trees
library(rpart.plot)  # enhanced version of rpart
library(xgboost) #extreme gradient boosting
library(shiny) #web application framework for R

#Load data
student_data <- read.csv("~/Capstone/student_data.csv")

#inspect first few rows
head(student_data)
str(student_data)

#check for missing values and decide how to handle them - either ipute missing values or remove them
colSums(is.na(student_data))  
sum(is.na(student_data))

#check for duplicates in data
duplicates <- student_data[duplicated(student_data), ]  #returns a dataframe with no obs if there are no duplicates

#explore the data /examine the variables
summary(student_data)
glimpse(student_data)

#Insect character variables
char_vars <- sapply(student_data, is.character)
char_cols <- names(student_data)[char_vars]
print(char_cols)

#how many categories does each of the char variables has?
sapply(student_data[, char_cols], function(x) length(unique(x)))

#what categories in each variable?
table(student_data$Mjob)
table(student_data$studytime)
table(student_data$famrel)  #keep as numeric variable to treat as a continuous variable in modelling
table(student_data$failures)  #keep as numeric variable to treat as a continuous variable in modelling
table(student_data$absences)

student_data20 <-  student_data %>%
  mutate_if(is.character, as.factor)

str(student_data20)
glimpse(student_data20)

#Convert categorical integer variables to factors
#by using as.factor, R will treat the integer values in the variable (suc as Medu with 0-4) as categories rather than numeric values. 
student_data20$Medu <- as.factor(student_data20$Medu)
student_data20$Fedu <- as.factor(student_data20$Fedu)
student_data20$studytime <- as.factor(student_data20$studytime)
student_data20$traveltime <- as.factor(student_data20$address)
student_data20$freetime <- as.factor(student_data20$school)
student_data20$goout <- as.factor(student_data20$internet)

#Omit rows with NAs
student_data20 <- na.omit(student_data20)

# #scale numeric features
# 
# student_data_scaled <- student_data20
# numeric_columns <- sapply()
# student_data_scaled[, sapply(student_data_scaled, is.numeric)] <- scale(student_data_scaled[, sapply(student_data_scaled, is.numeric)])

# Check correlations
cor_data <- cor(select(student_data20, where(is.numeric)))
rnd_cor_data <- round(cor_data, 2)
print(rnd_cor_data)

# Train-Test split  (Method 1)
set.seed(123)
index <-createDataPartition(student_data20$G3, p=0.8, list=FALSE)
train_data <- student_data20[index, ]  #model training dataset is 80% of the dataset. training needs more data. 
test_data <- student_data20[-index, ]

#why use randomForest regression - when relationship is non-linear, and complex. Useful when target variable is continuous. 
#non-linearity is determined when target variable(G#) and features variables(independent variables) ahve no relationship. see this in a scatter plot:

#Plot independent numeric variables vs dependent variable (G#)

names(student_data20)


plot(student_data20$feature, student_data20$G3,
main = "Scatter Plot of Feature vs G3",
xlab = "Feature", ylab = "Target (G3")

num_vars <- c("studytime", "failures", "absences", "Medu", "Fedu", "age", "famrel", "health", "higher", "internet", "romantic")

for (var in num_vars) {
  plot(student_data20[[var]], student_data20$G3,
  min = paste("Scatter Plot of", var, "vs G3"),
  xlab = var, ylab = "Target (G3)")
}

plot(student_data20$studytime, student_data20$G3,
     main = "Scatter Plot of Feature vs G3",
     xlab = "studytime", ylab = "Target (G3")


#training the randomforest model for regression  (use name space function package::function())

rf_model <- randomForest::randomForest(G3 ~ ., student_data20 = train_data, ntree = 100, mtry = 5, importance = TRUE)

summary(student_data20)


# Feature Importance
importance(rf_model)

# Step 6: Model Evaluation
pred <- predict(rf_model, test_data)
rmse <- sqrt(mean((test_data$G3 - pred)^2))
cat('RMSE:', rmse)

# Step 7: Save Model
saveRDS(rf_model, 'student_performance_model.rds')

# Step 8: Deployment with Plumber
# Create a Plumber API file named 'plumber.R'

# plumber.R
# library(plumber)
# rf_model <- readRDS('student_performance_model.rds')
#
# #* Predict student performance
# #* @param studytime
# #* @param absences
# #* @param failures
# #* @param G1
# #* @param G2
# #* @post /predict
# function(studytime, absences, failures, G1, G2) {
#   new_data <- data.frame(
#     studytime = as.numeric(studytime),
#     absences = as.numeric(absences),
#     failures = as.numeric(failures),
#     G1 = as.numeric(G1),
#     G2 = as.numeric(G2)
#   )
#   predict(rf_model, new_data)
# }

# Run API
# library(plumber)
# pr <- plumb('plumber.R')
# pr$run(port = 8000)


