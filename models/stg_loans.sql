with source as (

    select * from {{ ref('loan_data') }}

),

staged as (

    select
        id                          as loan_id,
        loan_amnt                   as loan_amount,
        funded_amnt                 as funded_amount,
        term                        as loan_term,
        int_rate                    as interest_rate,
        installment,
        grade                       as loan_grade,
        sub_grade,
        emp_length                  as employment_length,
        home_ownership,
        annual_inc                  as annual_income,
        loan_status,
        purpose                     as loan_purpose,
        dti                         as debt_to_income_ratio,
        delinq_2yrs                 as delinquencies_2yrs,
        earliest_cr_line            as earliest_credit_line,
        open_acc                    as open_accounts,
        pub_rec                     as public_records,
        revol_bal                   as revolving_balance,
        revol_util                  as revolving_utilization,
        total_acc                   as total_accounts,
        out_prncp                   as outstanding_principal,
        total_pymnt                 as total_payment,
        total_rec_prncp             as total_received_principal,
        total_rec_int               as total_received_interest,
        last_pymnt_amnt             as last_payment_amount

    from source

)

select * from staged