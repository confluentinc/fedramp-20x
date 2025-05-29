{% macro cmk_should_have_rotation_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('cmk_should_have_rotation_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__cmk_should_have_rotation_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__cmk_should_have_rotation_enabled(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Ensure rotation for customer created custom master keys is enabled (Scored)' as title,
    akk.arn as identifier,
    null as metadata,
    case when
             akkrs.key_rotation_enabled is FALSE and akk.key_manager = 'CUSTOMER'
             then 'fail'
         else 'pass'
        end as status
from {{ full_table_name("aws_kms_keys") }} akk
left join {{ full_table_name("aws_kms_key_rotation_statuses") }} akkrs on akk.arn = akkrs.key_arn
{% endmacro %}
