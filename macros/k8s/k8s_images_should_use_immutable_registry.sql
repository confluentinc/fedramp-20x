{% macro k8s_images_should_use_immutable_registry(framework, check_id) %}
  {{ return(adapter.dispatch('k8s_images_should_use_immutable_registry')(framework, check_id)) }}
{% endmacro %}

{% macro default__k8s_images_should_use_immutable_registry(framework, check_id) %}{% endmacro %}

{% macro bigquery__k8s_images_should_use_immutable_registry(framework, check_id) %}
with images as (
    select image_name from {{ full_table_name("k8s_container_images") }} group by image_name
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Kubernetes images should use an immutable registry' as title,
    image_name as identifier,
    null as metadata,
    case when er.repository_uri IS NOT NULL and er.image_tag_mutability = 'IMMUTABLE'
         then 'pass'
         else 'fail'
    end as status,
    tags
from images
left join {{ full_table_name("aws_ecr_repositories") }} as er
    on images.image_name = er.repository_uri
    {% endmacro %}