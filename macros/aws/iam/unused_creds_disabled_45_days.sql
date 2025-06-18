{% macro unused_creds_disabled_45_days(framework, check_id) %}
  {{ return(adapter.dispatch('unused_creds_disabled_45_days')(framework, check_id)) }}
{% endmacro %}

{% macro default__unused_creds_disabled_45_days(framework, check_id) %}{% endmacro %}


{% macro bigquery__unused_creds_disabled_45_days(framework, check_id) %}
select
       '{{framework}}' as framework,
       '{{check_id}}' as check_id,
       'Ensure credentials unused for 45 days or greater are disabled (Automated)' as title,
       SPLIT(arn, ':')[SAFE_OFFSET(4)] AS account_id,
       r.arn, 
       case
           when
                   (r.password_status in ('TRUE', 'true')
                        and r.password_last_used < (CURRENT_TIMESTAMP() - interval '45' day)
                       or (r.password_status in ('TRUE', 'true')
                           and r.password_last_used is null
                           and r.password_last_changed < (CURRENT_TIMESTAMP() - interval '45' day))
                       or (k.last_used < (CURRENT_TIMESTAMP() - interval '45' day)))
                   or (r.access_key1_active
                   and r.access_key_1_last_used_date < (CURRENT_TIMESTAMP() - interval '45' day))
                   or (r.access_key1_active
                   and r.access_key_1_last_used_date is null
                   and access_key_1_last_rotated < (CURRENT_TIMESTAMP() - interval '45' day))
                   or (r.access_key2_active
                   and r.access_key_2_last_used_date < (CURRENT_TIMESTAMP() - interval '45' day))
                   or (r.access_key2_active
                   and r.access_key_2_last_used_date is null
                   and access_key_2_last_rotated < (CURRENT_TIMESTAMP() - interval '45' day))
               then 'fail'
           else 'pass'
           end
from {{ full_table_name("aws_iam_credential_reports") }} r
         left join {{ full_table_name("aws_iam_user_access_keys") }} k on
        k.user_arn = r.arn and {{ partition_join("r", "k") }}
where {{ partition_filter("r") }}
{% endmacro %}
