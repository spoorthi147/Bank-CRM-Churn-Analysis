# Analytical CRM Development for a Bank

A customer churn analysis for a bank, using **MySQL** for analysis and **Power BI** for an interactive dashboard. The project explores why customers leave and recommends actions to improve retention.

## Problem Statement

The bank wants to reduce customer churn, improve service delivery and enhance customer satisfaction. As an analytical CRM specialist, the task is to extract insights from customer demographics, account details, exit information and activity profiles, to:

- Identify the key factors contributing to customer churn
- Identify profitable customer segments for tailored services
- Recommend practical retention strategies

## Dataset

Seven Excel tables describing **10,000 customers** who joined between 2016 and 2019:

| Table | Records | Description |
|---|---|---|
| Bank_Churn | 10,000 | CreditScore, Tenure, Balance, NumOfProducts, HasCrCard, IsActiveMember, Exited |
| CustomerInfo | 10,000 | Surname, Age, GenderID, EstimatedSalary, GeographyID, Bank DOJ |
| ActiveCustomer, CreditCard, ExitCustomer, Gender, Geography | 2–3 each | Lookup tables for category labels |

Data quality checks found no missing values and no duplicate customers.

## Tools Used

- **MySQL**: joins, CASE statements, CTEs, subqueries and window functions
- **Power BI**: Power Query for cleaning, data modelling, DAX measures and a five-page interactive dashboard
- **PowerPoint and Word**: presentation and written report

## Repository Structure

```
Bank-CRM-Churn-Analysis/
├── Data/            Source Excel files
├── SQL/             MySQL queries for the objective and subjective questions
├── PowerBI/         Power BI dashboard (.pbix)
├── Documentation/   Report with answers and insights (.docx)
└── Presentation/    Presentation for management (.pptx)
```

## Dashboard Pages

1. **Customer Churn Overview**: headline KPIs, geography split and monthly joining trend
2. **Customer Behaviour**: age, gender, salary and activity status
3. **Product & Banking Behaviour**: products, credit cards and balances
4. **Churn Intelligence**: churn rate by age, geography, tenure and credit score
5. **Churn Risk Analysis**: High, Medium and Low risk customers with conditional formatting

Slicers for geography, gender, activity status and age keep every page interactive.

## Key Findings

- Overall churn is **20.37%** (2,037 of 10,000 customers)
- **Germany** churns at 32.44%, about twice France (16.15%) and Spain (16.67%), while holding the highest average balance
- Customers with **one product** churn at 27.71%, against 7.58% for customers with two products
- Customers aged **50–59** churn at 56.04%
- **Inactive** members churn at 26.85%, against 14.27% for active members
- Credit card ownership, salary and credit score show little effect on churn

## Recommendations

1. Re-engage inactive members with targeted campaigns
2. Run a dedicated retention plan for Germany
3. Encourage single-product customers to adopt a second product
4. Offer personalised service to customers aged 40–60
5. Use the dashboard risk score to prioritise outreach

## Data Note

The `Exited` column is treated as the source of truth for churn. 735 customers are flagged as active members but have exited, so `IsActiveMember` is read as an activity indicator only.

## How to Use

1. Open `PowerBI/Analytical_CRM_Development_for_a_Bank_Spoorthi.pbix` in Power BI Desktop.
2. If the data does not refresh, update the source file path under **Transform data → Data source settings** to point to the `Data/` folder.
3. Run the queries in `SQL/Bank_CRM_Capstone_Solutions.sql` in MySQL after importing the Excel tables.

## Author

**Spoorthi**
