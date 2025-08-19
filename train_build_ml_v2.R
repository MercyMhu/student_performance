# Train-Test split  (Method 2)

library(ggplot2)
library(caret)
library(stats)
library(data.table)
library(tidyverse)
#Load data
#Capstone is a folder in 
student_data <- read.csv("~/Capstone/student_data.csv")

sum(is.na(student_data))

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

student_data20 <- student_data20 %>%
  mutate(
    avg_G <- rowMeans(student_data20[, c("G1", "G2")], na.rm=TRUE) 
  ) %>%
  select(-G1, -G2)

names(student_data20)


# Check correlations
cor_data <- cor(select(student_data20, where(is.numeric)))
rnd_cor_data <- round(cor_data, 1)
print(rnd_cor_data)

dummies <- dummyVars(G3 ~ ., data=student_data20)



#Apply the dummyVars transformation to the data
student_data_transformed <- predict(dummies, newdata=student_data20)

#convert the result to a data frame
student_data_transformed <- as.data.frame(student_data_transformed)


#Add back G3 to the transformed data
student_data_transformed$G3 <- student_data20$G3
names(student_data_transformed)

#Split data into training and testing

set.seed(123)
train_index <- createDataPartition(student_data_transformed$G3, p=0.7, list=FALSE)
train_data <- student_data_transformed[train_index, ]
test_data <- student_data_transformed[-train_index, ]


#model throwing high correlation error: Remove some of the variables with high correlation
high_corr <- findCorrelation(cor(train_data), cutoff=0.8)
print(high_corr)

train_data <- train_data[, -high_corr]

#train the model
model <- train(G3 ~ ., data=student_data_transformed, method="lm")


summary(model$finalModel)

#Assess the model

predictions <- predict(model, newdata = test_data)

mae <- mean(abs(predictions - test_data$G3))
mse <- mean((predictions - test_data$G3)^2)
rmse <- sqrt(mse)

# Display metrics
cat("Mean Absolute Error (MAE):", mae, "\n")
cat("Mean Squared Error (MSE):", mse, "\n")
cat("Root Mean Squared Error (RMSE):", rmse, "\n")


# Scatter plot of actual vs. predicted values  - for good model, the points shoul be close to the red dashed line which represents a perfect prediction
ggplot(data = test_data, aes(x = G3, y = predictions)) +
  geom_point(color = "blue") +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +
  labs(title = "Actual vs. Predicted Values",
       x = "Actual G3",
       y = "Predicted G3") +
  theme_minimal()

# Histogram of residuals - for good model, residuals should be normally distributed (bell shaped), centred around zero (errors are balanced)
residuals <- test_data$G3 - predictions
ggplot(data = data.frame(residuals), aes(x = residuals)) +
  geom_histogram(fill = "steelblue", bins = 15, color = "black") +
  labs(title = "Histogram of Residuals",
       x = "Residuals",
       y = "Frequency") +
  theme_minimal()

#check scatterplots and correation with other factors to see if this effect (Walc vs G3) is real or due to confounding

ggplot(student_data_transformed, aes(x=Walc, y=G3)) +
  geom_point() +
  geom_smooth(method="lm")


# X <- student_data_transformed[, -which(names(student_data_transformed) == "G3")]
# Y <- as.vector(student_data_transformed[["G3"]])
# Y <- c(student_data_transformed[["G3"]])
# str(Y)
# train_index <-createDataPartition(Y, p=0.7, list=FALSE)  #can also b written as train_index <-createDataPartition(student_data_transformed$G3, p=0.7, list=FALSE)
# 
# x_train <- X[train_index, ]
# x_test <- X[-train_index, ]
# 
# y_train <- Y[train_index]
# y_test <- Y[-train_index]
#   
#   student_data20[index, ]  #model training dataset is 70% of the dataset. training needs more data. 
# test_data <- student_data20[-index, ]
# 
# 
# model<- lm(y_train ~ x_train, data=student_data20)
