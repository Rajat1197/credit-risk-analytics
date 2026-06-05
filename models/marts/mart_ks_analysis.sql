with loans as (

    select * from {{ ref('int_loan_defaults') }}

),

scored as (

    select
        loan_id,
        loan_grade,
        is_default,
        debt_to_income_ratio,
        revolving_utilization,
        delinquencies_2yrs,
        outstanding_principal,

        -- Combined behavioural score
        -- Higher score = higher risk
        (
            case loan_grade
                when 'A' then 1
                when 'B' then 2
                when 'C' then 3
                when 'D' then 4
                when 'E' then 5
                else 3
            end * 0.4
        ) +
        (debt_to_income_ratio / 45.0 * 0.25) +
        (revolving_utilization / 100.0 * 0.20) +
        (least(delinquencies_2yrs, 3) / 3.0 * 0.15)
            as combined_risk_score,

        {{ ks_decile('combined_risk_score') }} as decile

    from loans

),

decile_summary as (

    select
        decile,
        count(*)                                    as total_loans,
        sum(is_default)                             as total_defaults,
        sum(1 - is_default)                         as total_non_defaults,
        sum(is_default) * 1.0 / 
            sum(sum(is_default)) over ()            as pct_defaults,
        sum(1 - is_default) * 1.0 / 
            sum(sum(1 - is_default)) over ()        as pct_non_defaults

    from scored
    group by decile

),

cumulative as (

    select
        decile,
        total_loans,
        total_defaults,
        total_non_defaults,
        pct_defaults,
        pct_non_defaults,
        sum(pct_defaults) over (
            order by decile
            rows between unbounded preceding and current row
        )                                           as cum_pct_defaults,
        sum(pct_non_defaults) over (
            order by decile
            rows between unbounded preceding and current row
        )                                           as cum_pct_non_defaults

    from decile_summary

),

ks_calc as (

    select
        decile,
        total_loans,
        total_defaults,
        total_non_defaults,
        round(cum_pct_defaults * 100, 2)            as cum_default_rate,
        round(cum_pct_non_defaults * 100, 2)        as cum_non_default_rate,
        round(abs(cum_pct_defaults - 
            cum_pct_non_defaults) * 100, 2)         as ks_value

    from cumulative

)

select
    *,
    max(ks_value) over ()                           as max_ks_statistic
from ks_calc
order by decile