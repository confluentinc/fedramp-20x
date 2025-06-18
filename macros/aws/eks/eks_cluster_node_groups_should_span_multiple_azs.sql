{% macro eks_cluster_node_groups_should_span_multiple_azs(framework, check_id) %}
  {{ return(adapter.dispatch('eks_cluster_node_groups_should_span_multiple_azs')(framework, check_id)) }}
{% endmacro %}

{% macro default__eks_cluster_node_groups_should_span_multiple_azs(framework, check_id) %}{% endmacro %}

{% macro bigquery__eks_cluster_node_groups_should_span_multiple_azs(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'EKS Clusters should have node groups in multiple availability zones' as title,
    eks.arn as identifier,
    null as metadata,
    case when az_count > 1
         then 'pass'
        else 'fail'
    end as status,
    eks.tags
from {{ full_table_name("aws_eks_clusters") }} eks
join (
    select cluster_name, region, count(distinct availability_zone) as az_count
    from {{ full_table_name("aws_eks_cluster_node_groups") }} as cng
    join unnest(subnets) as subnet
    join {{ full_table_name("aws_ec2_subnets") }} as subnet_data
    on subnet = subnet_data.subnet_id
    where {{ partition_filter("cng")}}
    group by cluster_name, region
) as subnet_az_count
on eks.name = subnet_az_count.cluster_name
and eks.region = subnet_az_count.region
and {{ partition_filter() }}
    {% endmacro %}
