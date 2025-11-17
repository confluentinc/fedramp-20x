{% macro okta_active_users_should_have_valid_training(framework, check_id) %}
  {{ return(adapter.dispatch('okta_active_users_should_have_valid_training')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_active_users_should_have_valid_training(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_active_users_should_have_valid_training(framework, check_id) %}

with active_users_with_employee_number as (
    select 
        user.id,
        JSON_VALUE(user.profile, "$.email") as email,
        JSON_VALUE(user.profile, "$.employeeNumber") as employee_number
    from {{ full_table_name("okta_users") }} as user
    where user.status = 'ACTIVE'
      and JSON_VALUE(user.profile, "$.employeeNumber") IS NOT NULL
      and JSON_VALUE(user.profile, "$.email") NOT LIKE '%admin%'
      and {{ partition_filter("user") }}
),
training_status as (
    select 
        training.employee_id,
        training.rules_of_behavior_completed_within_12_months,
        training.cyber_awareness_challenge_and_certificate_completed_within_12_months
    from {{ full_table_name("workday_training") }} as training
    where {{ partition_filter("training") }}
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Active users should have valid training' as title,
    users.employee_number as identifier,
    JSON_OBJECT(
        'employee_number', users.employee_number,
        'rules_of_behavior_completed', training.rules_of_behavior_completed_within_12_months,
        'cyber_awareness_completed', training.cyber_awareness_challenge_and_certificate_completed_within_12_months
    ) as metadata,
    case when training.rules_of_behavior_completed_within_12_months = '1'
              and training.cyber_awareness_challenge_and_certificate_completed_within_12_months = '1'
             then 'pass'
         else 'fail'
        end as status,
    JSON_OBJECT() as tags
from active_users_with_employee_number as users
left join training_status as training 
    on users.employee_number = training.employee_id

{% endmacro %}

