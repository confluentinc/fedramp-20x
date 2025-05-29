{% macro kms_key_should_have_rotation_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('kms_key_should_have_rotation_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__kms_key_should_have_rotation_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__kms_key_should_have_rotation_enabled(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'AWS KMS key rotation should be enabled' AS title,
    akk.arn AS identifier,
    null as metadata,
    CASE
        WHEN (akkrs.kms_key_should_have_rotation_enabled = false or akkrs.kms_key_should_have_rotation_enabled is null) AND akk.key_manager = 'CUSTOMER' THEN 'fail'
        ELSE 'pass'
        END as status
FROM
    {{ full_table_name("aws_kms_keys") }} akk
LEFT JOIN
  {{ full_table_name("aws_kms_key_rotation_statuses") }} akkrs on akk.arn = akkrs.key_arn
{% endmacro %}