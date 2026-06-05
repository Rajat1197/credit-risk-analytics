{% snapshot loan_status_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='loan_id',
        strategy='check',
        check_cols=['loan_status', 'risk_tier', 'is_default']
    )
}}

select
    loan_id,
    loan_amount,
    loan_grade,
    loan_status,
    risk_tier,
    dti_bucket,
    is_default,
    debt_to_income_ratio,
    annual_income,
    current_timestamp() as snapshot_taken_at

from {{ ref('int_loan_defaults') }}

{% endsnapshot %}