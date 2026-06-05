-- Macro 1: Calculate PSI bucket
-- PSI is what you monitored at EXL — now you're building it in dbt

{% macro psi_bucket(score_column) %}
    case
        when {{ score_column }} < 5  then 'Bucket_1'
        when {{ score_column }} between 5  and 10 then 'Bucket_2'
        when {{ score_column }} between 10 and 15 then 'Bucket_3'
        when {{ score_column }} between 15 and 20 then 'Bucket_4'
        when {{ score_column }} between 20 and 25 then 'Bucket_5'
        when {{ score_column }} between 25 and 30 then 'Bucket_6'
        when {{ score_column }} between 30 and 35 then 'Bucket_7'
        when {{ score_column }} between 35 and 40 then 'Bucket_8'
        when {{ score_column }} between 40 and 45 then 'Bucket_9'
        else 'Bucket_10'
    end
{% endmacro %}


-- Macro 2: Classify default risk
{% macro default_risk_label(is_default_column) %}
    case
        when {{ is_default_column }} = 1 then 'Defaulted'
        when {{ is_default_column }} = 0 then 'Performing'
        else 'Unknown'
    end
{% endmacro %}


-- Macro 3: Calculate months on book
{% macro months_on_book(start_date_column, end_date_column) %}
    datediff('month', {{ start_date_column }}, {{ end_date_column }})
{% endmacro %}

-- Macro 4: KS Statistic calculation helper
-- Assigns decile rank to a score for KS computation
-- KS = max(cumulative good rate - cumulative bad rate) across deciles

{% macro ks_decile(score_column) %}
    ntile(10) over (order by {{ score_column }} desc)
{% endmacro %}