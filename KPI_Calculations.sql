---Create temporary table for branch performance
CREATE TABLE #Bank_performance (
Avg_Earning_Assets DECIMAL(18,2),
Annual_Interest_Income DECIMAL(18,2),
Annual_Interest_Expense DECIMAL(18,2),
Avg_Total_Assets DECIMAL(18,2),
Annual_Total_Expenses DECIMAL(18,2),
Annual_Non_Interest_Income DECIMAL(18,2),
Avg_Shareholders_Equity DECIMAL(18,2)
);

---Insert Data into Temporary table after aggregated base data from different tables
WITH Loan_Inv as (
             SELECT 
              SUM(Outstanding_principal)/12 as Avg_Earning_Assets,
              ISNULL(SUM(Interest_income),0) as  Annual_Interest_Income
             FROM (SELECT Outstanding_principal,interest_income FROM Bank_Data..Loans$
                  UNION ALL 
                  SELECT Outstanding_principal,interest_income FROM Bank_Data..Investments$
) X ),Deposit as (
             SELECT
             ISNULL(SUM(Interest_expense),0) as Total_Deposit_Interest_Expense
             FROM Bank_Data..DEPOSITS$
),Equity as (
             SELECT
                 SUM(Share_capital + Reserves + Retained_earnings) / 12.0 AS Avg_Total_Share
             FROM Bank_Data..Equity$
),Other as (
           SELECT
            ISNULL(SUM(Operating_Cost),0) AS Total_Op_Costs,
            ISNULL(SUM(Interest_expense_other),0) AS Total_Other_Int_Expense,
            ISNULL(SUM(Non_Interest_income),0) AS Total_NonInt_Income,
            SUM(other_assets)/12 AS Avg_Other_Asset,
            ISNULL(SUM(fee_income),0) AS Total_Fee_Income,
            ISNULL(Sum(Tax),0) AS Total_Tax,
            Sum(cash_balance)/12 AS Avg_Cash,
            Sum(slr_balance)/12 AS Avg_SLR,
            Sum(crr_balance)/12 AS Avg_CRR
            FROM Bank_Data..Others$
),Provision as (
              SELECT
              ISNULL(SUM(provision_amount),0) AS Total_Provision
              FROM Bank_Data..Provisions$

)
INSERT INTO #Bank_performance 
SELECT 
     L.Avg_Earning_Assets,
     L.Annual_Interest_Income,
    (D.Total_Deposit_Interest_Expense + O.Total_Other_Int_Expense) AS Annual_Interest_Expense,
    (L.Avg_Earning_Assets + O.Avg_Cash + O.Avg_SLR + O.Avg_CRR + O.Avg_Other_Asset) AS Avg_Total_Assets,
    (D.Total_Deposit_Interest_Expense + O.Total_Other_Int_Expense + 
     O.Total_Op_Costs + O.Total_Tax + P.Total_Provision) AS Annual_Total_Expenses,
    (O.Total_NonInt_Income + O.Total_Fee_Income) AS Annual_Non_Interest_Income,
    (E.Avg_Total_Share) AS Avg_Shareholders_Equity
FROM Loan_Inv L
CROSS JOIN Deposit D
CROSS JOIN Equity E
CROSS JOIN Other O
CROSS JOIN Provision P;

SELECT*
FROM #Bank_performance

---Profitability Metrics
---NIM = (Interest Income - Interest Expense) / Total Earning Asset

SELECT 
    ROUND(((Annual_Interest_Income - Annual_Interest_Expense) 
               / NULLIF(Avg_Earning_Assets, 0)) * 100.0, 2) AS NIM_Percentage
FROM #Bank_performance;

--- Return to Shareholders (ROE)
--- ROE = Net Profit / Shareholder Equity

SELECT
       ROUND(((Annual_Interest_Income + Annual_Non_Interest_Income - Annual_Total_Expenses) 
        / NULLIF(Avg_Shareholders_Equity, 0)) * 100.0, 2) AS ROE_Percentage
FROM #Bank_performance;

--- Overall Profitability (ROA)
---ROA = Net Profit / Total Assets
---Total Assets = Earning Assets + Non-Earning Assets

SELECT 
       ROUND(((Annual_Interest_Income + Annual_Non_Interest_Income - Annual_Total_Expenses) 
        / NULLIF(Avg_Total_Assets, 0)) * 100.0, 2) AS ROA_Percentage
FROM #Bank_performance;

--- Income Efficiency (Yield on Asset)
--- Yield on Asset = Interest Income / Average Earning Asset

SELECT 
       ROUND((Annual_Interest_Income / NULLIF(Avg_Earning_Assets, 0)) * 100.0, 2) AS Yield_On_Assets 
FROM #Bank_performance;

--- NPA Risk / Asset Quality Metrics
--- Gross NPA = NPA Asset / Total Loans

WITH GROSS AS (
     SELECT
        SUM(CASE WHEN Loan_status ='NPA' THEN Outstanding_Principal ELSE 0 END) AS Total_Gross_NPA,
        SUM(Outstanding_Principal) AS Total_Gross_Advance
    FROM Bank_Data..Loans$
)
SELECT  
       ROUND((Total_Gross_NPA/NULLIF(Total_Gross_Advance,0))*100,2) as Gross_NPA
FROM GROSS;

--- Net NPA = (NPA Asset - Provisions) / (Total Loans - Provisions)

WITH GROSS AS (
     SELECT
        SUM(CASE WHEN Loan_status ='NPA' THEN Outstanding_Principal ELSE 0 END) AS Total_Gross_NPA,
        SUM(Outstanding_Principal) AS Total_Gross_Advance
    FROM Bank_Data..Loans$
), Provision as
( 
    SELECT 
        SUM(provision_amount) as provisions
    FROM Bank_Data..Provisions$ 
 )
 SELECT 
     ROUND(((G.Total_Gross_NPA - P.provisions)/(G.Total_Gross_Advance - P.provisions))*100,2) AS NET_NPA
FROM GROSS G
CROSS JOIN Provision P