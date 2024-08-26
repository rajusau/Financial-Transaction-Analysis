# Financial Transactions Analysis – Advanced SQL + Python Project

## Overview

This project involves analyzing financial transactions using SQL and Python. The aim is to develop a comprehensive SQL-based system for analyzing financial data, focusing on trend identification and fraud detection. The project includes complex SQL queries for data aggregation and metric computation, as well as Python for data visualization and insights extraction.

## Project Structure

- **SQL Queries**: SQL scripts for data extraction, aggregation, and analysis.
- **Python Scripts**: Python scripts for data visualization and further analysis.
- **Data**: Sample CSV files or database dumps used for analysis.

## Data

### Tables and Columns

1. **customers**
   - `customer_id`
   - `name`
   - `date_of_birth`
   - `address`
   - `contact_info`
   - `customer_since`

2. **accounts**
   - `account_id`
   - `customer_id`
   - `account_type`
   - `balance`
   - `creation_date`
   - `status`

3. **merchants**
   - `merchant_id`
   - `name`
   - `industry`
   - `location`

4. **transactions**
   - `transaction_id`
   - `account_id`
   - `merchant_id`
   - `amount`
   - `transaction_date`
   - `transaction_time`

5. **fraud_analysis**
   - `fraud_id`
   - `account_id`
   - `transaction_id`
   - `fraud_type`
   - `fraud_details`
   - `detection_date`

## Setup

### Prerequisites

- MySQL 8.0 or later
- Python 3.x
- Required Python libraries: `mysql-connector-python`, `pandas`, `matplotlib`, `seaborn`

### Installation

1. **Clone the repository**

   ```bash
   https://github.com/rajusau/Financial-Transaction-Analysis.git
   cd Financial-Transactions-Analysis
   ```


2. **Set up MySQL database**

   - Create a database in MySQL and import the provided SQL scripts or CSV data to set up tables.


## Usage

1. **Run SQL Queries**

   Execute the provided SQL scripts to create and populate tables, and perform data analysis.

2. **Run Python Scripts**

   Execute the Python scripts for data visualization:

   ```bash
   python Pyhton_Visualization.ipynb
   ```

   The script will generate various plots and visualizations based on the analysis performed.

## Visualizations

- **Monthly Transaction Amounts**: A bar chart showing total transaction amounts for each month.
- **Cumulative Transaction Amounts**: A line plot showing cumulative transaction amounts over time.
- **Distribution of Transaction Amounts**: A histogram showing the frequency distribution of transaction amounts.
- **Rolling Mean of Transaction Amounts**: A line plot showing the rolling mean of transaction amounts.
- **Monthly Transaction Amounts Heatmap**: A heatmap displaying transaction amounts across months.
- **Box Plot of Transaction Amounts**: A box plot showing the distribution and spread of transaction amounts.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any improvements or bug fixes.


## Contact

For any questions or feedback, please contact [Raju Sau](linkedin.com/in/rajusau).
