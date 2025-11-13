{% macro ecr_images_should_be_scanned_for_vulnerabilities(framework, check_id) %}
  {{ return(adapter.dispatch('ecr_images_should_be_scanned_for_vulnerabilities')(framework, check_id)) }}
{% endmacro %}

{% macro default__ecr_images_should_be_scanned_for_vulnerabilities(framework, check_id) %}{% endmacro %}

{% macro bigquery__ecr_images_should_be_scanned_for_vulnerabilities(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Container images should be scanned for vulnerabilities' as title,
    account_id,
    repository_name as resource_id,
    case when
        JSON_VALUE(image_scanning_configuration.scanOnPush) != 'true'
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_ecr_repositories") }}
where {{ partition_filter() }}
{% endmacro %}
