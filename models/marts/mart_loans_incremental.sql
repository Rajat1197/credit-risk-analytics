{{
    config(
        materialized='incremental',
        unique_key='loan_id'
    )
}}

with int_loans as (

    select * from {{ ref('int_loan_defaults') }}

),

final as (

    select
        loan_id,
        loan_amount,
        loan_grade,
        risk_tier,
        dti_bucket,
        income_band,
        is_default,
        debt_to_income_ratio,
        annual_income,
        loan_status,
        current_timestamp() as processed_at

    from int_loans

    {% if is_incremental() %}
        where loan_id not in (select loan_id from {{ this }})
    {% endif %}

)

select * from final