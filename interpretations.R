# This script details results interpreations and suggestions to improve model from train_build_ml_v2.R

# 1. Understanding the Estimates
# Each predictor variable has:
#   
#   Estimate: The coefficient that tells how much G3 changes when that predictor changes by 1 unit.
# 
# Std. Error: The variability in the coefficient estimate.
# 
# t value: The test statistic (Estimate / Std. Error).
# 
# Pr(>|t|) (p-value): Probability that the effect is due to random chance.
# 
# < 0.05: Statistically significant (marked with *).
# 
# < 0.01: Strongly significant (**).
# 
# < 0.001: Very strong significance (***).
# 
# 2. Key Variables & Their Interpretation
# Predictor	Estimate	Meaning
# age = -0.24434	For every additional year of age, G3 decreases by 0.24 points, holding all else constant. Since p = 0.0213 (*), this effect is statistically significant.	
# Fedu (Father's education) = 0.96109	Higher father’s education is associated with higher G3 scores (an increase of ~0.96 per unit of education level). This effect is significant (p = 0.0262, *).	
# schoolsup.no = -0.79164	Students without school support tend to score 0.79 points lower on G3. This is statistically significant (*p = 0.0182, ).	
# romantic.no = 0.53100	Students not in a romantic relationship tend to have 0.53 points higher G3. This is statistically significant (*p = 0.0236, ).	
# famrel (Family Relationship Quality) = 0.28011	Better family relationships are associated with higher G3 scores (0.28 per unit increase). Significant (*p = 0.0188, ).	
# absences = 0.04550	More absences are associated with higher G3 (0.045 per absence). p = 0.0015 (), meaning it is strongly significant.** However, this result is surprising—normally, more absences should lower grades.	
# avg_G (Average of G1 & G2) = 1.20947	The strongest predictor: for every 1-point increase in the average of G1 & G2, G3 increases by ~1.21 points. It is **highly significant (p < 2e-16, *).	
# 
# 
# 
# 3. Key Takeaways
# Age negatively impacts final grades → Older students tend to score lower.
# 
# Father’s education has a positive effect on grades.
# 
# Lack of school support negatively affects grades.
# 
# Not being in a romantic relationship is linked to slightly higher grades.
# 
# Better family relationships correlate with better performance.
# 
# Absences unexpectedly show a positive relationship (may need further investigation).
# 
# G1 and G2 averages are the strongest predictor of G3 (as expected).

########################################################################################################################################################################################################################################################################################

# Based on the results from your linear regression (lm) model, here are some observations and suggestions for potential improvements:
#   
#   1. Multicollinearity:
#   Issue: Several coefficients are not defined due to singularities (e.g., school.MS, sex.M, famsize.LE3, Pstatus.T, etc.), which likely indicates perfect multicollinearity or redundancy in the model.
# 
# Improvement:
#   
#   Check for highly correlated variables and remove one of each pair of correlated variables to address multicollinearity.
# 
# Use the vif() function (Variance Inflation Factor) from the car package to identify highly collinear predictors. You can then decide to remove or combine them.
# 
# 2. Significant Variables:
#   Observations:
#   
#   Some predictors like age, Fedu.1, schoolsup.no, romantic.no, famrel, and absences show significant effects (p-values less than 0.05), while others like sex.F, address.R, Pstatus.A, Mjob.at_home, etc., are not significant.
# 
# Improvement:
#   
#   Focus on significant predictors for model refinement. You could try stepwise selection (stepAIC) to reduce the model to only the most important predictors.
# 
# Consider interaction terms for variables that might work together to influence the outcome (e.g., age * absences, studytime * famrel).
# 
# 3. Model Performance:
#   Observations:
#   
#   The multiple R-squared value is relatively high (0.8307), suggesting that the model explains a good portion of the variance in the data.
# 
# However, the adjusted R-squared (0.8089) indicates that there may still be room for improvement. Some predictors might not be contributing meaningfully to the model.
# 
# Improvement:
#   
#   Use cross-validation (e.g., caret package) to assess model performance more robustly and avoid overfitting.
# 
# Explore non-linear relationships or transformations (logarithmic or polynomial terms) for variables that might have a non-linear influence on the outcome.
# 
# 4. Non-Linearity:
#   Issue: Some predictors, like studytime or famrel, might have non-linear effects.
# 
# Improvement:
#   
#   Use Generalized Additive Models (GAMs) (mgcv package) to model non-linear relationships between predictors and the outcome.
# 
# Alternatively, use polynomial terms for predictors that show non-linear trends.
# 
# 5. Handling Categorical Variables:
#   Issue: Variables like school and sex have missing coefficients due to the reference category being dropped. For example, sex.M is not included because it is the reference level.
# 
# Improvement:
#   
#   Ensure that categorical variables are properly coded using dummy variables (or factor encoding) to avoid dropping important levels. Consider if the reference categories are appropriate for the analysis.
# 
# 6. Interaction Terms:
#   Issue: The current model does not include any interaction terms, which may be important if predictors interact with one another in affecting the outcome.
# 
# Improvement:
#   
#   You could add interaction terms between predictors that you suspect might work together (e.g., age * schoolsup.no, famrel * romantic.no).
# 
# 7. Alternative Modeling Approaches:
#   Improvement:
#   
#   Random Forests (randomForest package): This model can handle non-linearities and interactions naturally without requiring explicit interaction terms or transformations.
# 
# Gradient Boosting Machines (GBM): Methods like xgboost or lightgbm can handle complex relationships and provide more flexibility.
# 
# Lasso or Ridge Regression (glmnet package): These regularization methods can help deal with multicollinearity by shrinking some coefficients to zero, essentially performing variable selection.
# 
# 8. Model Evaluation:
#   Improvement:
#   
#   In addition to looking at the p-values, evaluate the model with residual plots, AIC/BIC, and cross-validation to assess model performance.
# 
# Check if the assumptions of linear regression (e.g., normality of residuals, homoscedasticity, independence) are met. If not, consider transforming variables or using different models like robust regression.
# 
# 9. Model Tuning:
#   Improvement:
#   
#   Fine-tune hyperparameters if you switch to models like random forests or GBM. For example, you can adjust the number of trees, the depth of trees, or learning rates.
# 
# Final Model Suggestions:
#   Generalized Additive Model (GAM): This would allow for more flexibility by modeling the relationship between predictors and the outcome as non-linear functions.
# 
# Random Forest or XGBoost: These are ensemble learning methods that can capture complex interactions and non-linearities, especially when you have many predictors and interactions.
# 
# Lasso Regression: This is especially useful if you want to perform variable selection automatically.