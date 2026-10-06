
--=================================================================
--BANK CUSTOMER CHURN & RETENTION ANALYSIS
--=================================================================

CREATE TABLE bank_churn (
    customer_id BIGINT,
    surname VARCHAR(100),
    credit_score INTEGER,
    geography VARCHAR(50),
    gender VARCHAR(20),
    age INTEGER,
    tenure INTEGER,
    balance NUMERIC(15,2),
    num_of_products INTEGER,
    has_credit_card INTEGER,
    is_active_member INTEGER,
    estimated_salary NUMERIC(15,2),
    exited INTEGER
);
SELECT * FROM bank_churn;





--========================================================
--DATA VALIDATION
--========================================================





--Checking for total rows.
SELECT COUNT(*) AS total_cus  FROM bank_churn;

--Checking for duplicate customer ids.

SELECT customer_id,
COUNT(*) AS duplicate_cusid 
FROM bank_churn
GROUP BY customer_id HAVING COUNT(*)>1;

--Checking for missing values

SELECT
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS customer_id_count,
    COUNT(surname) AS surname_count,
    COUNT(credit_score) AS credit_score_count,
    COUNT(geography) AS geography_count,
    COUNT(gender) AS gender_count,
    COUNT(age) AS age_count,
    COUNT(tenure) AS tenure_count,
    COUNT(balance) AS balance_count,
    COUNT(num_of_products) AS num_of_products_count,
    COUNT(has_credit_card) AS has_cr_card_count,
    COUNT(is_active_member) AS active_member_count,
    COUNT(estimated_salary) AS salary_count,
    COUNT(exited) AS exited_count
FROM bank_churn;

--Checking minimum and maximum age.

SELECT MAX(age) AS max_age, MIN(age) AS min_age
FROM bank_churn;

--Checking for maximum and minimum number of products a customer can have.

SELECT MAX(num_of_products) AS max_num_of_products, MIN(num_of_products) AS min_num_of_products
FROM bank_churn;

--Checking values in gender.

SELECT DISTINCT(gender) AS gender_check 
FROM bank_churn;

--Checking values in geography.

SELECT DISTINCT(geography) AS geo_check
FROM bank_churn;

--Checking has credit card for only 0 and 1.

SELECT DISTINCT(has_credit_card) AS check_has_credit_card
FROM bank_churn;

--Checking is active members for only 0 and 1.

SELECT DISTINCT(is_active_member) AS check_is_active_member
FROM bank_churn;

--Checking exited for only 0 and 1.

SELECT DISTINCT(exited) AS check_exited
FROM bank_churn;

-- Checking the maximum and minimum values in credit score, tenure, balance, and estimated salary.

SELECT MAX(credit_score) AS max_credit_score,
	   MIN(credit_score) AS min_credit_score,
	   MAX(tenure) AS max_tenure,
	   MIN(tenure) AS min_tenure,
	   MAX(balance) AS max_balance,
	   MIN(balance) AS min_balance,
	   MAX(estimated_salary) AS max_estimated_salary,
	   MIN(estimated_salary) AS min_estimated_salary
FROM bank_churn;





--========================================================
--BUSINESS ANALYSIS
--========================================================





--Q1. WHAT IS THE TOTAL CUSTOMER BASE?
SELECT COUNT(*) AS total_cus
FROM bank_churn;

--Q2. WHAT IS THE OVERALL CUSTOMER CHURN RATE?
SELECT COUNT(*) FILTER(WHERE exited = 1) * 100.00
	   /COUNT(*) AS churn_rate
FROM bank_churn;

--Q3. WHAT PROPORTION OF THE CUSTOMER BASE IS CURRENTLY ACTIVE?
SELECT COUNT(*) FILTER(WHERE is_active_member = 1) * 100.00
		/COUNT(*) AS active_members_rate
FROM bank_churn;		

--Q4. HOW MANY CUSTOMERS HAVE CHURNED?
SELECT COUNT(*) AS churned_customers
FROM bank_churn
WHERE exited = 1;

--Q5. HOW DOES CHURN RATE VARY BY GEOGRAPHY?
SELECT geography,
	   COUNT(*)FILTER(WHERE exited = 1) * 100.00
	   /COUNT(*) AS churn_rate_by_geo
FROM bank_churn
GROUP BY geography;

--Q6. HOW DOES CHURN RATE VARY BY AGE GROUPS?
WITH age_groups AS (
    SELECT
        CASE
            WHEN age BETWEEN 18 AND 29 THEN '18-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69'
            WHEN age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS age_group,
        exited
    FROM bank_churn
)

SELECT age_group,
    	COUNT(*) FILTER (WHERE exited = 1) * 100.0
    	/COUNT(*) AS churn_rate_age
FROM age_groups
GROUP BY age_group;

--Q7. HOW DOES CHURN RATE VARY BY GENDER?
SELECT gender,
	   COUNT(*)FILTER(WHERE exited = 1) * 100.00
	   /COUNT(*) AS churn_rate_by_gender
FROM bank_churn
GROUP BY gender;

--Q8. HOW DOES CHURN RATE VARY BY TENURE?
SELECT tenure,
	   COUNT(*)FILTER(WHERE exited = 1) * 100.00
	   /COUNT(*) AS churn_rate_by_tenure
FROM bank_churn
GROUP BY tenure;

--Q9. IS ACTIVITY STATUS ASSOCIATED WITH CHURN?
SELECT is_active_member, COUNT(*)FILTER (WHERE exited = 1) * 100.00
						 /COUNT(*) AS churn_rate 
FROM bank_churn
GROUP BY is_active_member;

--Q10. DOES  NUMBER OF PRODUCTS HELD AFFECT CHURN?
SELECT num_of_products, COUNT(*)FILTER (WHERE exited = 1) * 100.00
					   /COUNT(*) AS churn_rate
FROM bank_churn
GROUP BY num_of_products;


--Q11. DOES CREDIT CARD OWNERSHIP RELATE TO CHURN?
SELECT has_credit_card, COUNT(*)FILTER (WHERE exited = 1) * 100.00
					   /COUNT(*) AS churn_rate
FROM bank_churn
GROUP BY has_credit_card;

--Q12. HOW DOES CHURN VARY ACROSS ACCOUNT BALANCE RANGES?
WITH account_balance_range AS (
    SELECT
        CASE
            WHEN balance BETWEEN  0.00       AND 50000.00   THEN  '0-50,000'
            WHEN balance BETWEEN  50001.00   AND 100000.00  THEN  '50,001-100,000'
            WHEN balance BETWEEN  100001.00  AND 150000.00  THEN  '100,001-150,000'
            WHEN balance BETWEEN  150001.00  AND 200000.00  THEN  '150,001-200,000'
            WHEN balance BETWEEN  200001.00  AND 250000.00  THEN  '200,001-250,000'
            ELSE '250,000+'
        END AS  account_balance_range,
        exited
    FROM bank_churn
)

SELECT
     account_balance_range,
    COUNT(*) FILTER (WHERE exited = 1) * 100.0
    / COUNT(*) AS churn_rate_balance
FROM  account_balance_range
GROUP BY  account_balance_range;

--Q13. HOW DOES CREDIT SCORE DIFFER BETWEEN CHURNED AND RETAINED CUSTOMERS?
SELECT exited, AVG(credit_score) AS avg_credit_score
FROM bank_churn
GROUP BY exited;

--Q14. HOW DOES ESTIMATED SALARY DIFFER BETWEEN CHURNED AND RETAINED CUSTOMERS?
SELECT exited, AVG(estimated_salary) AS avg_estimate_salary
FROM bank_churn
GROUP BY exited;

--Q15. WHICH CUSTOMER SEGMENTS HAVE THE HIGHEST CHURN RATES?
 SELECT geography, is_active_member,
 COUNT(*)FILTER (WHERE exited = 1) * 100.00
 /COUNT(*) AS churn_rate
 FROM bank_churn
 GROUP BY geography, is_active_member;

--Q16. WHAT COMBINATION OF CUSTOMER CHARACTERISTICS APPEARS MOST ASSOCIATED WITH CHURN?
WITH age_groups AS (
    SELECT geography,
        CASE
            WHEN age BETWEEN 18 AND 29 THEN '18-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69'
            WHEN age BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS age_group,
        exited
    FROM bank_churn
)

SELECT geography, age_group, 
    	COUNT(*) AS total_customers,
		COUNT(*)FILTER (WHERE exited = 1) AS churned_customers,
    	COUNT(*)FILTER(WHERE exited = 1) * 100.00
		/COUNT(*) AS churn_rate
FROM age_groups
GROUP BY  geography, age_group
HAVING COUNT(*)>= 50
ORDER BY churn_rate DESC;






-- =====================================================
-- KEY BUSINESS INSIGHTS
-- =====================================================






-- Overall churn rate: 20.37%.
-- 2,037 out of 10,000 customers have churned.



-- 1. GEOGRAPHY

-- Germany has the highest churn rate at 32.44%,
-- compared with 16.15% in France and 16.67% in Spain.
-- This indicates a substantial difference in churn across geographic segments.



-- 2. AGE

-- Churn varies considerably across age groups.
-- Customers aged 50-59 have the highest churn rate at 56.04%,
-- followed by customers aged 60-69 at 35.20% and 40-49 at 30.78%.
-- Younger customers aged 18-29 have a much lower churn rate of 7.55%.



-- 3. ACTIVITY STATUS

-- Inactive customers have a churn rate of 26.85%, compared with 14.26% among active customers.
-- This shows a substantial difference in churn between active and inactive customers.



-- 4. ACCOUNT BALANCE

-- Churn generally increases across several higher balance segments, reaching 54.54% for 
-- customers with balances between 200,001 and 250,000.
-- The 250,000+ segment shows a 100% churn rate, but this segment should be interpreted 
-- cautiously because its customer count is very small.



-- 5. ESTIMATED SALARY

-- Average estimated salary is 99,738 among churned customers and 101,465 among retained
-- customers.
-- The relatively small difference suggests that estimated salary shows less separation
-- between churned and retained customers than some of the other customer characteristics.



-- 6. GENDER

-- Female customers have a churn rate of 25.07%, Compared with 16.45% among male customers.
-- Indicating a notable difference in churn rates between the two gender groups.































