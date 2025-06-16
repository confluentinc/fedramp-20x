{% macro k8s_images_should_use_immutable_tags(framework, check_id) %}
  {{ return(adapter.dispatch('k8s_images_should_use_immutable_tags')(framework, check_id)) }}
{% endmacro %}

{% macro default__k8s_images_should_use_immutable_tags(framework, check_id) %}{% endmacro %}

{% macro bigquery__k8s_images_should_use_immutable_tags(framework, check_id) %}

select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Kubernetes images should use versioned tags instead of named aliases' as title,
    CONCAT(context, '.', namespace, '.', resource_name, '.', container_name) as identifier,
    null as metadata,
    case when image_tag IN ('master', 'latest', 'stable')
        then 'fail'
        else 'pass'
    end as status,
    null as tags
from {{ full_table_name("k8s_container_images") }}
    {% endmacro %}