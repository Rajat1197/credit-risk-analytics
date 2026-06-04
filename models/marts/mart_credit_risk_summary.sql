with int_loans as (

    select * from {{ ref('int_loan_defaults') }}

),

risk_summary as (

    select
        risk_tier,
        dti_bucket,
        income_band,
        loan_grade,

        -- Volume metrics
        count(loan_id)                              as total_loans,
        sum(loan_amount)                            as total_loan_amount,
        avg(loan_amount)                            as avg_loan_amount,

        -- Default metrics
        sum(is_default)                             as total_defaults,
        avg(is_default) * 100                       as default_rate_pct,

        -- Portfolio health
        avg(debt_to_income_ratio)                   as avg_dti,
        avg(annual_income)                          as avg_annual_income,
        avg(interest_rate)                          as avg_interest_rate,

        -- Risk distribution
        sum(case when is_default = 1
            then loan_amount else 0 end)            as defaulted_loan_amount,
        sum(case when is_default = 0
            then loan_amount else 0 end)            as performing_loan_amount

    from int_loans

    group by
        risk_tier,
        dti_bucket,
        income_band,
        loan_grade

)

select * from risk_summary
order by default_rate_pct desc