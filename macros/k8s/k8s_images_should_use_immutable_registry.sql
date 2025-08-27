{% macro k8s_images_should_use_immutable_registry(framework, check_id) %}
  {{ return(adapter.dispatch('k8s_images_should_use_immutable_registry')(framework, check_id)) }}
{% endmacro %}

{% macro default__k8s_images_should_use_immutable_registry(framework, check_id) %}{% endmacro %}

{% macro bigquery__k8s_images_should_use_immutable_registry(framework, check_id) %}
with images as (
    select REPLACE(image_name, 'ecr-fips', 'ecr') as image_name
    from {{ full_table_name("k8s_container_images") }}
    group by image_name
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Kubernetes images should use an immutable registry' as title,
    images.image_name as identifier,
    JSON_OBJECT() as metadata,
    case
      when er.repository_uri IS NOT NULL and er.image_tag_mutability = 'IMMUTABLE'
        then 'pass'

      when STARTS_WITH(images.image_name, '013241004608.dkr.ecr.us-gov-west-1.amazonaws.com')
        then 'pass'

      when STARTS_WITH(images.image_name, 'gke.gcr.io')
        then 'pass'

      else 'fail'
    end as status,
    tags
from images
left join {{ full_table_name("aws_ecr_repositories") }} as er
    on images.image_name = REPLACE(er.repository_uri, 'ecr-fips', 'ecr')
    and {{ partition_filter("er") }}
    and re.repository_uri not like '%/helm/%'
    and re.repository_uri not like '%/docker/dev/%'
    {% endmacro %}
