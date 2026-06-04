with loans as (

    select * from {{ ref('stg_loans') }}

),

defaults_flagged as (

    select
        loan_id,
        loan_amount,
        funded_amount,
        loan_term,
        interest_rate,
        loan_grade,
        employment_length,
        home_ownership,
        annual_income,
        loan_purpose,
        debt_to_income_ratio,
        loan_status,

        -- Default flag: 1 if charged off, 0 if fully paid
        case
            when loan_status = 'Charged Off' then 1
            else 0
        end as is_default,

        -- Risk tier based on loan grade
        case
            when loan_grade in ('A') then 'Low Risk'
            when loan_grade in ('B', 'C') then 'Medium Risk'
            when loan_grade in ('D', 'E') then 'High Risk'
            when loan_grade in ('F', 'G') then 'Very High Risk'
            else 'Unknown'
        end as risk_tier,

        -- DTI risk bucket
        case
            when debt_to_income_ratio < 10 then 'Low DTI'
            when debt_to_income_ratio between 10 and 20 then 'Medium DTI'
            when debt_to_income_ratio between 20 and 35 then 'High DTI'
            when debt_to_income_ratio > 35 then 'Very High DTI'
            else 'Unknown'
        end as dti_bucket,

        -- Income band
        case
            when annual_income < 30000 then 'Low Income'
            when annual_income between 30000 and 60000 then 'Medium Income'
            when annual_income between 60000 and 100000 then 'High Income'
            when annual_income > 100000 then 'Very High Income'
            else 'Unknown'
        end as income_band

    from loans

)

select * from defaults_flagged