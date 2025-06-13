{% macro k8s_container_images(table) %}
  {{ return(adapter.dispatch('k8s_container_images')(table)) }}
{% endmacro %}

{% macro default__k8s_container_images(table) %}{% endmacro %}

{% macro bigquery__k8s_container_images(table) %}
WITH coalesced_data AS (
    SELECT
        JSON_VALUE(container, '$.image') as image,
        context as context,
        '{{ table }}' as resource_type,
        name as resource_name,
        JSON_VALUE(container, '$.name') as container_name,
        namespace,
    FROM {{ full_table_name(table) }},
    UNNEST(JSON_QUERY_ARRAY(spec_template.spec.containers)) AS container
    WHERE {{ partition_filter() }}
    {{ union() }}
    SELECT
        JSON_VALUE(container, '$.image') as image,
        context as context,
        '{{ table }}' as resource_type,
        name as resource_name,
        JSON_VALUE(container, '$.name') as container_name,
        namespace,
    FROM {{ full_table_name(table) }},
    UNNEST(JSON_QUERY_ARRAY(spec_template.spec.initContainers)) AS container
    WHERE {{ partition_filter() }}
    )
SELECT
    *,
    REGEXP_EXTRACT(image, r'^(.*):[^:]*$') as image_name,
    REGEXP_EXTRACT(image, r':([^:]+)$') as image_tag
FROM coalesced_data
{% endmacro %}