{% macro ecr_repositories_should_have_immutable_tags(framework, check_id) %}
  {{ return(adapter.dispatch('ecr_repositories_should_have_immutable_tags')(framework, check_id)) }}
{% endmacro %}

{% macro default__ecr_repositories_should_have_immutable_tags(framework, check_id) %}{% endmacro %}

{% macro bigquery__ecr_repositories_should_have_immutable_tags(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'ECR private repositories should have tag immutability configured' as title,
    arn as identifier,
    null as metadata,
    CASE
        WHEN image_tag_mutability <> 'IMMUTABLE' THEN 'fail'
        ELSE 'pass'
        END as status
FROM
    {{ full_table_name("aws_ecr_repositories") }}
{% endmacro %}