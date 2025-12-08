{% macro workday_employee_should_have_completed_security_training(framework, check_id) %}
  {{ return(adapter.dispatch('workday_employee_should_have_completed_security_training')(framework, check_id)) }}
{% endmacro %}

{% macro default__workday_employee_should_have_completed_security_training(framework, check_id) %}{% endmacro %}

{% macro bigquery__workday_employee_should_have_completed_security_training(framework, check_id) %}

with training_data as (
    select 
        employee_id,
        security_awareness_completion_date,
        -- Check if security awareness training is completed within the past 12 months
        case 
            when security_awareness_completion_date != ''
                 and PARSE_DATE('%m/%d/%Y', security_awareness_completion_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
            then true 
            else false 
        end as security_awareness_valid
    from {{ full_table_name("workday_engineering_training") }} as training
    where {{ partition_filter("training") }}
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Workday employees should have completed security awareness training within the past 12 months' as title,
    employee_id as identifier,
    JSON_OBJECT(
        'employee_id', employee_id,
        'security_awareness_completion_date', security_awareness_completion_date,
        'security_awareness_valid', security_awareness_valid
    ) as metadata,
    case 
        when security_awareness_valid
        then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from training_data

{% endmacro %}
