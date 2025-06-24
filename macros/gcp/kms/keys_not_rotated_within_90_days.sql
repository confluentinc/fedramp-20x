{% macro kms_keys_not_rotated_within_90_days(framework, check_id) %}
  {{ return(adapter.dispatch('kms_keys_not_rotated_within_90_days')(framework, check_id)) }}
{% endmacro %}

{% macro default__kms_keys_not_rotated_within_90_days(framework, check_id) %}{% endmacro %}

{% macro bigquery__kms_keys_not_rotated_within_90_days(framework, check_id) %}
select
        name as resource_id,
        '{{framework}}' as framework,
        '{{check_id}}' as check_id,
        'Ensure KMS encryption keys are rotated within a period of 90 days (Automated)'
        as title,
        project_id as project_id,
        case
            when
                (
                    INTERVAL CAST( (rotation_period/1000000000.0) AS INT64 ) SECOND
                    > INTERVAL 90 DAY
                )
                or next_rotation_time is null
                or TIMESTAMP_DIFF(next_rotation_time, CURRENT_TIMESTAMP(), DAY) > 90
            then 'fail'
            else 'pass'
        end as status
    from {{ full_table_name("gcp_kms_crypto_keys") }}
    where {{ partition_filter() }}
{% endmacro %}
