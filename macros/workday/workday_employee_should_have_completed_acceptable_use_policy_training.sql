{% macro workday_employee_should_have_completed_acceptable_use_policy_training(framework, check_id) %}
  {{ return(adapter.dispatch('workday_employee_should_have_completed_acceptable_use_policy_training')(framework, check_id)) }}
{% endmacro %}

{% macro default__workday_employee_should_have_completed_acceptable_use_policy_training(framework, check_id) %}{% endmacro %}

{% macro bigquery__workday_employee_should_have_completed_acceptable_use_policy_training(framework, check_id) %}

with training_data as (
    select 
        employee_id,
        acceptable_use_policy_completion_date,
        -- Check if acceptable use policy training is completed within the past 12 months
        case 
            when acceptable_use_policy_completion_date is not null 
                 and PARSE_DATE('%Y-%m-%d', acceptable_use_policy_completion_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
            then true 
            else false 
        end as acceptable_use_policy_valid
    from {{ full_table_name("workday_engineering_training") }} as training
    where {{ partition_filter("training") }}
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Workday employees should have completed acceptable use policy training within the past 12 months' as title,
    employee_id as identifier,
    JSON_OBJECT(
        'employee_id', employee_id,
        'acceptable_use_policy_completion_date', acceptable_use_policy_completion_date,
        'acceptable_use_policy_valid', acceptable_use_policy_valid
    ) as metadata,
    case 
        when acceptable_use_policy_valid
        then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from training_data

{% endmacro %}

