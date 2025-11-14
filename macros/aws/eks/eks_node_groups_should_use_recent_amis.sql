{% macro eks_node_groups_should_use_recent_amis(framework, check_id) %}
  {{ return(adapter.dispatch('eks_node_groups_should_use_recent_amis')(framework, check_id)) }}
{% endmacro %}

{% macro default__eks_node_groups_should_use_recent_amis(framework, check_id) %}{% endmacro %}

{% macro bigquery__eks_node_groups_should_use_recent_amis(framework, check_id) %}
-- Check EKS node groups use AMIs created within the last 30 days
with node_group_launch_templates as (
    select
        ng.account_id,
        ng.cluster_name,
        ng.nodegroup_name,
        JSON_VALUE(ng.launch_template.Id) as launch_template_id,
        ng.created_at as nodegroup_created_at
    from {{ full_table_name("aws_eks_cluster_node_groups") }} ng
    where {{ partition_filter("ng") }}
        and ng.status = 'ACTIVE'
),
launch_template_versions as (
    select
        ltv.account_id,
        ltv.launch_template_id,
        JSON_VALUE(ltv.launch_template_data.ImageId) as image_id,
        ltv.create_time as template_create_time
    from {{ full_table_name("aws_ec2_launch_template_versions") }} ltv
    where {{ partition_filter("ltv") }}
),
ami_ages as (
    select
        img.account_id,
        img.image_id,
        img.creation_date,
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), img.creation_date, DAY) as ami_age_days
    from {{ full_table_name("aws_ec2_images") }} img
    where {{ partition_filter("img") }}
)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'EKS node groups should use AMIs created within the last 30 days for security patches' as title,
    concat(ng.cluster_name, '/', ng.nodegroup_name) as identifier,
    JSON_OBJECT() as metadata,
    case when
        ami.ami_age_days > 30
        or ami.ami_age_days is null
        then 'fail'
        else 'pass'
    end as status,
    JSON_OBJECT() as tags
from node_group_launch_templates ng
left join launch_template_versions ltv 
    on ng.launch_template_id = ltv.launch_template_id
    and ng.account_id = ltv.account_id
left join ami_ages ami
    on ltv.image_id = ami.image_id
    and ltv.account_id = ami.account_id
{% endmacro %}
