{% macro config_enabled_all_regions(framework, check_id) %}
  {{ return(adapter.dispatch('config_enabled_all_regions')(framework, check_id)) }}
{% endmacro %}

{% macro default__config_enabled_all_regions(framework, check_id) %}{% endmacro %}
                    
{% macro bigquery__config_enabled_all_regions(framework, check_id) %}
with global_recorders as (
  select
    count(*) as global_config_recorders
  from
    {{ full_table_name("aws_config_configuration_recorders") }}
  where
    CAST( JSON_VALUE(recording_group.IncludeGlobalResourceTypes) AS BOOL) IS TRUE
    and CAST( JSON_VALUE(recording_group.AllSupported) AS BOOL) IS TRUE
    and status_recording is true
    and status_last_status = 'SUCCESS'
    and {{ partition_filter() }}
)
select
    distinct
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'AWS Config should be enabled' as title,
    r.account_id,
    r.arn as resource_id,
    case 
    when a.opt_in_status = 'not-opted-in' then ''
    when g.global_config_recorders >= 1
    and status_recording is true
    and status_last_status = 'SUCCESS' then 'pass'
    else 'fail'
  end as status
from
  global_recorders g,
  {{ full_table_name("aws_regions") }} a
  inner join {{ full_table_name("aws_config_configuration_recorders") }} r on r.account_id = a.account_id
  and r.region = a.region_name
  where a.opt_in_status != 'not-opted-in'
  and {{ partition_filter("a") }}
{% endmacro %}
