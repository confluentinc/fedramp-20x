{% macro k8s_images_should_use_internal_registry(framework, check_id) %}
  {{ return(adapter.dispatch('k8s_images_should_use_internal_registry')(framework, check_id)) }}
{% endmacro %}

{% macro default__k8s_images_should_use_internal_registry(framework, check_id) %}{% endmacro %}

{% macro bigquery__k8s_images_should_use_internal_registry(framework, check_id) %}
with images as (
    select image_name from {{ full_table_name("k8s_container_images") }} group by image_name
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Kubernetes images should use an internal registry' as title,
    image_name as identifier,
    JSON_OBJECT() as metadata,
    case when JSON_EXTRACT_SCALAR(FORMAT("%T", NET.HOST(image_name))) IN ({{ to_sql_list(var("ksi_cna_04_allowed_registries")) }})
        then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from images
    {% endmacro %}