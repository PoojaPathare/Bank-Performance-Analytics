#Bank Financial Performance & Risk Analysis for Financial Year (FY2025 – SQL)
Financial Year (FY) KPI Evaluation using SQL
Banking financial metrics analysis using SQL
Bank Financial Performance & Risk Analysis (FY2025)
📌 Problem Statement
Banks must continuously evaluate their financial stability and risk exposure. This project focuses on the 2025 Fiscal Year performance(simulated, calendar-year based: January–December 2025), analyzing the bank’s profitability and credit risk across five core domains: Loans, Deposits, Investments, Equity, and Provisions. By quantifying key financial metrics, the bank can identify trends in income generation and loan performance to drive data-backed strategic decisions.

🎯 Project Objective
The goal is to calculate and interpret the essential Key Performance Indicators (KPIs) for defining bank success for the Financial Year 2025:

Net Interest Margin (NIM): To evaluate the spread between interest earned and interest paid.

Return on Assets (ROA): To measure management's efficiency in using assets to generate net income.

Return on Equity (ROE): To assess profitability from the perspective of shareholders.

Yield on Assets: To determine the interest-generating power of the bank's asset base.

NPA Ratios (Gross & Net): To quantify credit risk and the quality of the loan portfolio.

🛠️ Technical Implementation
The analysis is built using T-SQL and utilizes a modular approach with Common Table Expressions (CTEs) and temporary tables to aggregate data points.

Data Architecture
The script processes data from the following relational tables in the Bank_Data database:

Loans$: Analyzes outstanding principals and interest income.

INVESTMENTS$: Aggregates investment income and asset values.

DEPOSITS$: Tracks interest expenses paid to customers.

Equity$: Calculates average share capital, reserves, and retained earnings.

Others$: Captures operating costs, taxes, and statutory balances (Cash, SLR, CRR).

Provisions$: Tracks the capital set aside for credit losses.
