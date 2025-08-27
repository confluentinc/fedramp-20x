{% macro full_asset_inventory() %}
  {{ return(adapter.dispatch('full_asset_inventory')()) }}
{% endmacro %}

{% macro default__full_asset_inventory() %}{% endmacro %}

{% macro bigquery__full_asset_inventory() %}
select
    r.arn as unique_asset_identifier,
    NULL as ip_address,
    true as is_virtual,
    false as is_public,
    case
        when (_cq_table = "aws_elbv2_load_balancers" and elb.scheme = "internet-facing") then elb.dns_name
        else NULL
    end as dns_name,
    NULL as netbios_name,
    NULL as mac_address,
    true as has_authenticated_scan,
    case
        when _cq_table = "aws_ecr_repositories" then re.repository_uri
        else NULL
        end as baseline_configuration_name,
    case
        when _cq_table = "aws_ecr_repositories" then "Container OS"
        else "N/A"
        end as os_name_and_version,
    r.region as location,
    case _cq_table
        when "aws_ecr_repositories" then "Container"
        when "aws_ec2_instances" then "EC2 Instance"
        when "aws_s3_buckets" then "S3 Bucket"
        when "aws_rds_instances" then "RDS Instance"
        when "aws_sqs_queues" then "Message Queue"
        when "aws_elbv2_load_balancers" then "Load Balancer"
        when "aws_elasticache_replication_groups" then "ElastiCache Instance"
        when "aws_lambda_functions" then "Lambda Function"
        when "aws_dynamodb_tables" then "DynamoDB Table"
        else NULL
        end as asset_type,
    NULL as hardware_model,
    true as in_latest_scan,
    case
        when _cq_table = "aws_ecr_repositories" then "Container Image"
        else "N/A"
    end as software_vendor,
    NULL as software_name_and_version,
    case _cq_table
        when "aws_ecr_repositories" then "None"
        when "aws_ec2_instances" then "Compute"
        when "aws_s3_buckets" then "Storage"
        when "aws_rds_instances" then "Database"
        when "aws_sqs_queues" then "Message Queue"
        when "aws_elbv2_load_balancers" then "Load Balancing"
        when "aws_elasticache_replication_groups" then "Cache"
        when "aws_lambda_functions" then "Serverless Compute"
        when "aws_dynamodb_tables" then "Database"
        else NULL
    end as patch_level,
    "Confluent Cloud for Government Authorization Boundary" as diagram_label,
    NULL as comments,
    NULL as asset_tag,
    NULL as network_id,
    NULL as system_administrator,
    "N/A" as application_administrator,
    NULL as function,
    NULL as end_of_life_date
from {{ ref("aws_resources") }} r
left join {{ full_table_name("aws_ecr_repositories") }} re
    on re.arn = r.arn and {{ partition_filter("re") }}
    and re.repository_uri not like '%/helm/%'
    and re.repository_uri not like '%/docker/dev/%'
left join {{ full_table_name("aws_ec2_instances") }} instance on instance.arn = r.arn and {{ partition_filter("instance") }}
left join {{ full_table_name("aws_rds_instances") }} database on database.arn = r.arn and {{ partition_filter("database") }}
left join {{ full_table_name("aws_sqs_queues") }} queue on queue.arn = r.arn and {{ partition_filter("queue") }}
left join {{ full_table_name("aws_elbv2_load_balancers") }} elb on elb.arn = r.arn and {{ partition_filter("elb") }}
left join {{ full_table_name("aws_elasticache_replication_groups") }} elasticache on elasticache.arn = r.arn and {{ partition_filter("elasticache") }}
left join {{ full_table_name("aws_lambda_functions") }} lambda on lambda.arn = r.arn and {{ partition_filter("lambda") }}
left join {{ full_table_name("aws_dynamodb_tables") }} dynamo on dynamo.arn = r.arn and {{ partition_filter("dynamo") }}
where _cq_table IN (
    "aws_ecr_repositories",
    "aws_ec2_instances",
    "aws_s3_buckets",
    "aws_rds_instances",
    "aws_sqs_queues",
    "aws_elbv2_load_balancers",
    "aws_elasticache_replication_groups",
    "aws_lambda_functions",
    "aws_dynamodb_tables"
)
{% endmacro %}