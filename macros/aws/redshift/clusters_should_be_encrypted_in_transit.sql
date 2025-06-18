{% macro clusters_should_be_encrypted_in_transit(framework, check_id) %}
  {{ return(adapter.dispatch('clusters_should_be_encrypted_in_transit')(framework, check_id)) }}
{% endmacro %}

{% macro default__clusters_should_be_encrypted_in_transit(framework, check_id) %}{% endmacro %}

{% macro bigquery__clusters_should_be_encrypted_in_transit(framework, check_id) %}
SELECT
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Connections to Amazon Redshift clusters should be encrypted in transit' as title,
    account_id,
    arn as resource_id,
    'fail' as status -- TODO FIXME
FROM {{ full_table_name("aws_redshift_clusters") }} as rsc
WHERE EXISTS (
    SELECT 1
    FROM {{ full_table_name("aws_redshift_cluster_parameter_groups") }} as rscpg
    INNER JOIN {{ full_table_name("aws_redshift_cluster_parameters") }} as rscp
        ON rscpg.cluster_arn = rscp.cluster_arn and {{ partition_join("rscpg", "rscp") }}
    WHERE rsc.arn = rscpg.cluster_arn
        AND (
            (rscp.parameter_name = 'require_ssl' AND rscp.parameter_value = 'false')
            OR (rscp.parameter_name = 'require_ssl' AND rscp.parameter_value IS NULL)
            OR NOT EXISTS (
                SELECT 1
                FROM {{ full_table_name("aws_redshift_cluster_parameters") }}
                WHERE cluster_arn = rscpg.cluster_arn
                    AND parameter_name = 'require_ssl'
            )
        ) and {{ partition_filter("rscpg")}}
)
AND {{ partition_filter("rsc") }}
{% endmacro %}
