create database Healthcare_claims;
 
 use Healthcare_claims; 
 select * from Healthcare_claims;

 -- Query 1) How much money was billed vs reimbursed overall?
 --This query tells:

--Total claims count.. count because characater 

--Total money billed... sum / number

--Total money reimbursed / sum

--Reimbursement percentage (how much insurance actually paid) ... will do divided then into 100 for %

select count(*)as 'Total Claims',
sum (Billed_Amount)as 'Total_billed_Money',
sum(Reimbursement_Amount)as 'Total_Reimbursed_Money',
(sum(Reimbursement_Amount)/ SUM(Billed_Amount))*100 as 'Reimbursed %'
from Healthcare_claims;

--Out of ₹55.12 lakh billed to insurance companies, only ₹28.50 lakh was reimbursed.The overall reimbursement rate is ~52%, 
--meaning hospitals received just about half of the billed amount.

---------------------------------------------------------------------------

-- Query 2: Status Distribution (Approved vs Denied)

--Claims have statuses: Approved or Denied.

--We need to group by Claim_Status

--Then count claims in each status.

select Claim_Status, COUNT(*) as 'Total_claims'
from Healthcare_claims
Group BY Claim_Status;

--Around 21% of the claims were denied.This indicates that denial management is an important area for improvement.
-------------------------------------------------------------------------------------------

--Query 3: Denial Rate by Payer.
--Step 1 → Get total claims per payer
--Step 2 → Get denied claims per payer
--Step 3 → Join both tables and calculate %



SELECT 
    t.Payer,
    t.Total_Claims,
    d.Denied_Claims,
    (d.Denied_Claims * 100.0) / t.Total_Claims AS Denial_Percentage
FROM 
    (SELECT Payer, COUNT(*) AS Total_Claims
     FROM Healthcare_claims
     GROUP BY Payer) t
JOIN
    (SELECT Payer, COUNT(*) AS Denied_Claims
     FROM Healthcare_claims
     WHERE Claim_Status = 'Denied'
     GROUP BY Payer) d
ON t.Payer = d.Payer;


-- Query 4) Reimbursement Performance by Payer 
-- So we will calculate for each Payer:

-- Total billed amount

-- Total reimbursed amount

-- Reimbursement Percentage = (Total reimbursed / Total billed) × 100

select Payer, sum(Billed_Amount) as 'Total_billed_Amount',
	sum (Reimbursement_Amount) as 'Total_Reimbursement',
	(sum (Reimbursement_Amount)/sum(Billed_Amount)*100) as 'Reimbursement %'
from Healthcare_claims
group by Payer;

-- Cigna and Medicare have the highest reimbursement percentages (~53–54%), meaning they tend to pay hospitals more consistently.
-- BCBS and Aetna show lower reimbursement percentages (~50%), indicating potential negotiation or denial management
-- improvement areas.

--------------------------------------------------------------------------

--Query 6 — Top 5 Procedures by Reimbursement
-- Group by Procedure_Code

-- Sum up Reimbursement_Amount

-- Sort descending

-- Show top 5

select top 5 Procedure_code, 
	count (*) as 'Total_count',
	sum (Reimbursement_Amount) as 'Total_Reimbursement'
from Healthcare_claims
group by Procedure_Code
order by sum (Reimbursement_Amount) DESC;

--Procedure Code CPT-11730 generates the highest reimbursement amount among all procedures.

------------------------------------------------------------------------------------------------

-- Query 7: Most Common Denial Reasons
--- not null have to use 
-- Only denied claims matter → so we filter Claim_Status = 'Denied'
--We look at Denial_Reason
--We count occurrences
--We sort highest first

SELECT 
    Denial_Reason,
    COUNT(*) AS Total_Denied_Claims
FROM Healthcare_claims
WHERE Claim_Status = 'Denied'
  AND Denial_Reason IS NOT NULL
  AND Denial_Reason <> ''      -- this removes empty text also
GROUP BY Denial_Reason
ORDER BY Total_Denied_Claims DESC;

--Query 8 — Data Quality Check
--Find how many denied claims are missing denial reason.
--This helps check coding/documentation errors.

SELECT 
    COUNT(*) AS Missing_Denial_Reason_Count
FROM Healthcare_claims
WHERE Claim_Status = 'Denied' 
AND (Denial_Reason IS NULL OR Denial_Reason = '');

"SELECT Claim_status,Denial_Reason
from Healthcare_claims
where Claim_Status = 'Denied'"

--All denied claims have a valid denial reason recorded. There are no missing or blank denial reasons in your dataset.

