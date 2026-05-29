import pandas as pd

def model(dbt, session):
    # Configure the python model to materialize as a physical table
    dbt.config(
        materialized="table",
        packages=["pandas"]
    )
    
    # Fetch dim_customer as a pandas dataframe
    df = dbt.ref("dim_customer").to_pandas()
    
    # Standardize column casing to uppercase for Snowflake compatibility
    df.columns = [col.upper() for col in df.columns]
    
    # Calculate a normalized value score from 0-100
    max_balance = df['TOTAL_BALANCE'].max() if df['TOTAL_BALANCE'].max() > 0 else 1.0
    max_loan = df['TOTAL_LOAN_PRINCIPAL'].max() if df['TOTAL_LOAN_PRINCIPAL'].max() > 0 else 1.0
    
    df['NORMALIZED_BALANCE'] = df['TOTAL_BALANCE'] / max_balance
    df['NORMALIZED_LOAN'] = df['TOTAL_LOAN_PRINCIPAL'] / max_loan
    
    df['CUSTOMER_VALUE_SCORE'] = (
        (df['NORMALIZED_BALANCE'] * 60) + 
        (df['ACTIVE_ACCOUNTS_COUNT'] * 10) + 
        (df['ACTIVE_CARDS_COUNT'] * 15) +
        (df['NORMALIZED_LOAN'] * 15)
    ).round(2)
    
    # Apply Python-based segmentation logic
    def assign_segment(row):
        score = row['CUSTOMER_VALUE_SCORE']
        balance = row['TOTAL_BALANCE']
        
        if balance >= 100000 or score >= 75:
            return 'High Net Worth (HNW) / VIP'
        elif balance >= 25000 or score >= 45:
            return 'Premier / Mass Affluent'
        elif balance > 0:
            return 'Active Standard Retail'
        else:
            return 'Inactive / Zero Balance'
            
    df['CUSTOMER_SEGMENT'] = df.apply(assign_segment, axis=1)
    
    # Select clean subset of columns for the final Snowflake table
    final_cols = [
        'CUST_ID', 'FULL_NAME', 'EMAIL', 'COUNTRY', 'AGE', 
        'TOTAL_BALANCE', 'TOTAL_ACCOUNTS_COUNT', 'ACTIVE_CARDS_COUNT', 
        'CUSTOMER_VALUE_SCORE', 'CUSTOMER_SEGMENT'
    ]
    
    return df[final_cols]