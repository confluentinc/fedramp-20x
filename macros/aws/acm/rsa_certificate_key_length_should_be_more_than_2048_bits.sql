{% macro rsa_certificate_key_length_should_be_more_than_2048_bits(framework, check_id) %}
  {{ return(adapter.dispatch('rsa_certificate_key_length_should_be_more_than_2048_bits')(framework, check_id)) }}
{% endmacro %}

{% macro default__rsa_certificate_key_length_should_be_more_than_2048_bits(framework, check_id) %}{% endmacro %}

{% macro bigquery__rsa_certificate_key_length_should_be_more_than_2048_bits(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'rsa certificate key length is less than 2048 bits' as title,
  account_id,
  arn AS resource_id,
  CASE
  WHEN key_algorithm IN ('RSA-1024', 'RSA 1024', 'RSA_1024')
  THEN 'fail' 
  ELSE 'pass'
  END AS status
FROM {{ full_table_name("aws_acm_certificates") }}
WHERE left(key_algorithm, 3) = 'RSA'
AND {{ partition_filter() }}
{% endmacro %}
