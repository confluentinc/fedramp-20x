{% macro aws_inventory_by_vpc() %}
  {{ return(adapter.dispatch('aws_inventory_by_vpc')()) }}
{% endmacro %}

{% macro default__aws_inventory_by_vpc() %}{% endmacro %}

{% macro bigquery__aws_inventory_by_vpc() %}
{%- for table in var('vpc_inventory_tables') -%}
select
    arn,
    tags,
    account_id,
    {%- if table == 'aws_ec2_vpc_peering_connections' -%}
        JSON_EXTRACT_SCALAR(accepter_vpc_info, "$.VpcId") as vpc_id
    {%- elif table == 'aws_rds_instances' -%}
        JSON_EXTRACT_SCALAR(db_subnet_group, "$.VpcId") as vpc_id
    {%- elif table == 'aws_eks_clusters' -%}
        JSON_EXTRACT_SCALAR(resources_vpc_config, "$.VpcId") as vpc_id
    {%- elif table == 'aws_lambda_functions' -%}
        JSON_EXTRACT_SCALAR(configuration, "$.VpcConfig.VpcId") as vpc_id
    {%- else -%}
        vpc_id
    {%- endif -%},
    '{{ table }}' as resource_type
from {{ full_table_name(table) }} where {{ partition_filter() }}
    {%- if not loop.last -%}{{ union() }}{%- endif -%}
{%- endfor -%}
{% endmacro %}