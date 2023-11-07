# Rideshare Cohort Analysis 

## Project Overview

This project focuses on analyzing a ridesharing platform's database to extract insights into driver activity, ride profitability, and user engagement. 
The primary goal is to determine the percentage of active drivers within specific cohorts over time and to understand the relationship between driver registration and ride activities.

## Data Model

The database consists of several tables including `members`, `rides`, `member_car`, etc. The main entities are the members who can be riders or drivers, rides that represent the trips taken, and member_car which links members to their vehicles.

## Methods Used

The analysis is conducted using advanced SQL queries, primarily Common Table Expressions (CTEs) to segment data into logical parts for easier manipulation and analysis:

1. **CTEs for Data Segmentation**: The data is first segmented into various CTEs like `drivers_rides`, `quarterly_cohorts`, `segment_rides`, and `drivers_quarterly_cohorts`. This step simplifies the data handling and prepares it for the final computation.

2. **Cohort Analysis**: Members are divided into cohorts based on their inscription quarter. This method helps in tracking the activity of drivers from the same signup period.

3. **Active Driver Calculation**: By comparing the ride activities to the cohorts, the active drivers are identified, allowing for the calculation of active driver percentages per cohort.

4. **Temporal Segmentation**: Rides are categorized by the quarter in which they took place, allowing for a time-based analysis of driver activity.

## SQL Optimization Techniques

To ensure efficient data retrieval and processing, the following optimizations were applied:

- **Selective Column Retrieval**: Only the necessary columns are fetched to reduce the data load.
- **Inner Joins**: Joins are used selectively to combine only relevant data from different tables.
- **Use of Aggregate Functions**: Counting distinct members to avoid duplication in metrics.
- **Date Functions**: `DATEDIFF` and other date functions are used for temporal calculations.
- **Logical Ordering**: Data is ordered logically at each step to facilitate easier understanding and processing.
- **NULL Handling**: Division by zero errors is prevented by using the `NULLIF` function in percentage calculations.


