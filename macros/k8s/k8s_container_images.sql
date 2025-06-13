{% macro k8s_container_images(table) %}
  {{ return(adapter.dispatch('k8s_container_images')(table)) }}
{% endmacro %}

{% macro default__k8s_container_images(table) %}{% endmacro %}

{% macro bigquery__k8s_container_images(table) %}
WITH coalesced_data AS (
    SELECT
        COALESCE(JSON_EXTRACT_SCALAR(container.image), JSON_EXTRACT_SCALAR(initContainer.image)) as image,
        context as context,
        '{{ table }}' as resource_type,
        name as resource_name,
        COALESCE(JSON_EXTRACT_SCALAR(container.name), JSON_EXTRACT_SCALAR(initContainer.name)) as container_name,
        namespace,
    FROM {{ full_table_name(table) }},
    UNNEST(JSON_QUERY_ARRAY(spec_template.spec.containers)) AS container,
    UNNEST(JSON_QUERY_ARRAY(spec_template.spec.initContainers)) AS initContainer
    WHERE {{ partition_filter() }}
    )
SELECT
    *,
    split(image, ':')[offset(0)] as image_name,
    split(image, ':')[offset(1)] as image_tag
FROM coalesced_data
{% endmacro %}