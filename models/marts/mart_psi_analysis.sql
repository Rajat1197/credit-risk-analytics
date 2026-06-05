with loans as (

    select * from {{ ref('int_loan_defaults') }}

),

bucketed as (

    select
        loan_id,
        loan_grade,
        debt_to_income_ratio,
        is_default,
        {{ psi_bucket('debt_to_income_ratio') }}    as dti_psi_bucket,
        {{ default_risk_label('is_default') }}       as risk_label

    from loans

),

psi_summary as (

    select
        dti_psi_bucket,
        risk_label,
        count(*)                                    as total_loans,
        sum(is_default)                             as total_defaults,
        round(avg(is_default) * 100, 2)             as default_rate_pct,
        round(avg(debt_to_income_ratio), 2)         as avg_dti

    from bucketed
    group by dti_psi_bucket, risk_label

)

select * from psi_summary
order by dti_psi_bucket, risk_label