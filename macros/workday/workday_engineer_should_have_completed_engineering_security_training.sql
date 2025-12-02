{% macro workday_engineer_should_have_completed_engineering_security_training(framework, check_id) %}
  {{ return(adapter.dispatch('workday_engineer_should_have_completed_engineering_security_training')(framework, check_id)) }}
{% endmacro %}

{% macro default__workday_engineer_should_have_completed_engineering_security_training(framework, check_id) %}{% endmacro %}

{% macro bigquery__workday_engineer_should_have_completed_engineering_security_training(framework, check_id) %}

with training_data as (
    select 
        employee_id,
        engineering_security_awareness_training_completion_date,
        -- Check if engineering security awareness training is completed within the past 12 months
        case 
            when engineering_security_awareness_training_completion_date is not null 
                 and PARSE_DATE('%Y-%m-%d', engineering_security_awareness_training_completion_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
            then true 
            else false 
        end as engineering_security_awareness_valid
    from {{ full_table_name("workday_engineering_training") }} as training
    where {{ partition_filter("training") }}
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Workday engineers should have completed engineering security awareness training within the past 12 months' as title,
    employee_id as identifier,
    JSON_OBJECT(
        'employee_id', employee_id,
        'engineering_security_awareness_training_completion_date', engineering_security_awareness_training_completion_date,
        'engineering_security_awareness_valid', engineering_security_awareness_valid
    ) as metadata,
    case 
        when engineering_security_awareness_valid
        then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from training_data

{% endmacro %}

