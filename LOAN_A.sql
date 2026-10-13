create database bank_loan;
use bank_loan;
select * from loan_approved_clean;
select count(*) from loan_approved_clean;
alter table loan_approved_clean rename to loan_a;
select * from loan_a;

alter table loan_a drop Myunknowncolumn;
select * from loan_a;
-- Basic SQL Queries 
-- 1. View the first 10 records from the table.
select * from loan_a limit 10;

-- 2. Count the total number of loan applications.
 select count(*) as total_applicants from loan_a;

-- 3. List all unique property areas.
select distinct(Property_Area) from loan_a;
select Property_Area,count(Property_Area) from loan_a group by Property_Area;

-- 4. Show all applicants who are self-employed and have an income above 5000.
select * from loan_a where Self_Employed = 'yes' and  ApplicantIncome > 5000;
select count(*) from loan_a where Self_Employed = 'yes' and  ApplicantIncome > 5000;

-- 5. Find the total number of approved loans
select count(Loan_Status) from loan_a where Loan_Status = 'Y';
select count(*) from loan_a where Loan_Status = 'Y';

-- Aggregation & Grouping 

-- 6. Find average loan amount by education level. 
select Education , round(avg(LoanAmount),2) as avg_loan_amount from loan_a group by Education;

-- 7. Find average total income (Applicant + Coapplicant) by marital status. 
select married, round(avg(applicantincome+coapplicantincome),2) as avg_income from loan_a group by married;

-- 8. Show average loan amount by credit history.
select Credit_History,round(avg(LoanAmount),2) as avg_loan_amount from loan_a group by Credit_History;

-- 9. Find total applications and approval rate by gender. 
select gender , count(*) as applicants ,
				sum(case when loan_status ='Y' then 1 else 0 end) as approved,
				round(sum(case when loan_status ='Y' then 1 else 0 end) /count(*) *100,2) as approval_rate
                from loan_a group by gender;

                
-- 10. Show approval rate by property area. 
select Property_Area , count(*) as applicants ,
					sum(case when loan_status ='Y' then 1 else 0 end) as approved,
					round(sum(case when loan_status ='Y' then 1 else 0 end) /count(*) *100,2) as approval_rate 
                    from loan_a group by Property_Area; 

-- Filtering & Conditions 

-- 11. Show applicants who are graduates, not self-employed, and have loan amount greater than 150. 
select * from loan_a where Education = 'graduate' and Self_Employed = 'No' and LoanAmount > 150;
select count(*) from loan_a where Education = 'graduate' and Self_Employed = 'No' and LoanAmount > 150;

-- 12. Display approved loans from urban area with good credit history. 
select * from loan_a where Property_Area = 'urban' and Credit_History = 1;
select count(*) from loan_a where Property_Area = 'urban' and Credit_History = 1;

-- 13. List top 5 applicants with highest total income.
select * from loan_a order by ApplicantIncome+CoapplicantIncome  desc limit 5;

 -- Derived Columns & CASE WHEN 
-- 14. Create derived columns for total income for each applicant. 
select *,ApplicantIncome+CoapplicantIncome as total_income from loan_a;

-- 15. Classify applicants into income groups (Low, Medium, High) based on applicant income. 
select Loan_ID , ApplicantIncome,
				case when ApplicantIncome <=3000 then 'low income'
				when ApplicantIncome >3000 and ApplicantIncome<=5000 then 'medium income'
				else 'high income'
                end as income_group from loan_a;

 
-- 16. Find average loan amount for each income group. 
				select 
				case when ApplicantIncome <=3000 then 'low income'
				when ApplicantIncome >3000 and ApplicantIncome<=5000 then 'medium income'
				else 'high income'
                end as income_group ,
                round(avg(loanamount),2) as avg_loanamount
                from loan_a group by income_group;

 -- Subqueries & Nested Analysis 
-- 17. Find applicants whose loan amount is greater than the overall average loan amount.
select * from loan_a 
where LoanAmount >(select avg(loanamount) from loan_a);

-- 18. Identify the property area with the highest average total income. 
select property_area , avg(ApplicantIncome+CoapplicantIncome) as avg_total_income from loan_a
group by property_area order by avg_total_income desc limit 1;

-- 19. List all applicants whose income is above the average income of their education category. 
SELECT *
FROM loan_a
WHERE ApplicantIncome > (
    SELECT AVG(ApplicantIncome)
    FROM loan_a AS l2
    WHERE l2.Education = loan_a.Education
);

-- Window Functions 

-- 20. Rank applicants based on total income (highest income rank = 1).
select Loan_ID ,
		ApplicantIncome+CoapplicantIncome as total_income,
        rank () over (order by (ApplicantIncome+CoapplicantIncome)desc) as rank_number from loan_a;
        
-- 21. Show average loan amount per property area using a window function. 
select property_area,
		avg(loanamount) over (partition by property_area)as avg_area_loan from loan_a;
        
        -- or
        select distinct(property_area),
        		avg(loanamount) over (partition by property_area)as avg_area_loan from loan_a;

-- 22. Calculate approval rate by education using grouping or window function. 
SELECT
    Education,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        AS Approved_Loans,
    ROUND(
        100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS Approval_Rate
FROM loan_a
GROUP BY Education;

-- or
SELECT DISTINCT
    Education,
    COUNT(*) OVER (
        PARTITION BY Education
    ) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        OVER (PARTITION BY Education) AS Approved_Loans,
    ROUND(
        100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        OVER (PARTITION BY Education)
        / COUNT(*) OVER (PARTITION BY Education), 2
    ) AS Approval_Rate
FROM loan_a;

-- Business Insights & Combined Analysis 

-- 23. Compare approval rate by credit history and education level to find which combination performs best.
SELECT
    Credit_History,
    Education,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        AS Approved_Loans,
    ROUND(
        100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS Approval_Rate
FROM loan_a
GROUP BY Credit_History, Education
ORDER BY Approval_Rate DESC;
 
-- 24. Find the combination of property area and education with the highest approval rate. 
SELECT
    Property_Area,
    Education,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        AS Approved_Loans,
    ROUND(
        100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS Approval_Rate
FROM loan_a
GROUP BY Property_Area, Education
ORDER BY Approval_Rate DESC
LIMIT 1;

-- 25. Compare approval rate for self-employed vs non-self-employed applicants by credit history.
SELECT
    Self_Employed,
    Credit_History,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        AS Approved_Loans,
    ROUND(
        100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS Approval_Rate
FROM loan_a
GROUP BY Self_Employed, Credit_History
ORDER BY Credit_History DESC, Approval_Rate DESC;