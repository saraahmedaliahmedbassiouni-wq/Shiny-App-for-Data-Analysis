#  Grocery Data Analysis Project 

##  Overview
This project is a full **data analysis pipeline built in R**, designed to analyze grocery transaction data.  
It includes **data cleaning, visualization, clustering, association rule mining, and an interactive Shiny dashboard**.

The goal is to transform raw grocery data into meaningful insights that help understand customer behavior, spending patterns, and item relationships.

---

##  Problem Statement

The program performs full data analysis in the following steps:

### 1. What does the program do?
- Cleans raw data
- Summarizes data
- Visualizes data using a dashboard
- Performs clustering (K-Means)
- Extracts association rules (Apriori algorithm)

---

### 2. Input
- Raw grocery transaction dataset
- Number of clusters (K) → range: 2 to 4
- Minimum support and confidence values (0.001 to 1)

---

### 3. Output
- Cleaned dataset
- Data summary
- Visual dashboard:
  - Pie chart (cash vs credit)
  - Scatter plot (age vs total spending)
  - Bar chart (city vs spending)
  - Histogram (spending distribution)
- Clustering results
- Association rules table

---

##  Dataset Components

- Items purchased
- Quantity of items
- Total spending
- Unique customer ID (RND)
- Customer name
- Age
- City
- Payment type

---

##  Data Cleaning

Performed using R:

- Remove duplicates → `distinct()`
- Handle missing values → `na.omit()`
- Filter invalid values → `filter(total > 0)`
- Convert data types → `mutate()`
- Remove outliers using boxplot method

---

##  Clustering (K-Means)

- Algorithm: **K-Means Clustering**
- Used to group customers based on:
  - Age
  - Total spending
- Key idea:
  - K defines number of groups (2–4)
    
---
## Association Rules (Apriori Algorithm):

Used to discover relationships between purchased items.

- Steps:
  - Convert dataset into transaction format
  - Apply Apriori algorithm
  - Set minimum support and confidence
  - Extract rules
- Packages used:
  - arules
  - arulesViz
    
---
## Data Visualization:
 - Pie Chart (Payment Type)
    Cash vs Credit distribution
    Result: Cash slightly higher than credit
 - Scatter Plot (Age vs Spending)
   Shows relationship between age and total spending
   Highest spending observed at ages:
    22
    37
    55
- Bar Chart (City vs Total Spending)
   Cities with highest spending:
   Alexandria
   Cairo
   Hurghada
- Histogram (Spending Distribution)
  Minimum spending: 100
  Maximum spending: 2500
  Median: 1297
- Cluster Visualization
  Shows customer grouping based on K values:
  K = 2
  K = 3
  K = 4

  ---
## Dashboard (Shiny App):

Built using R Shiny

### Features:
Interactive UI
Real-time analysis
Multiple visualization tabs
User-controlled inputs
Key Functions:
fluidPage()
sidebarPanel()
tabsetPanel()
reactive()
renderPlot()
renderTable()

---

## How to Run
install.packages("shiny")
library(shiny)

runApp("app.R")
