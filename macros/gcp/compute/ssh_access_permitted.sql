{% macro compute_ssh_access_permitted(framework, check_id) %}
  {{ return(adapter.dispatch('compute_ssh_access_permitted')(framework, check_id)) }}
{% endmacro %}

{% macro default__compute_ssh_access_permitted(framework, check_id) %}{% endmacro %}

{% macro bigquery__compute_ssh_access_permitted(framework, check_id) %}
WITH combined AS (
    SELECT * FROM {{ full_table_name("gcp_compute_firewalls") }} gcf, 
    UNNEST(JSON_QUERY_ARRAY(gcf.allowed)) AS a
    WHERE {{ partition_filter("gcf") }}
),
gcp_firewall_allowed_rules AS (
SELECT 
    gcf.project_id,
    gcf.name,
    gcf.network,
    gcf.self_link AS link,
    gcf.direction,
    gcf.source_ranges,
    JSON_VALUE(gcf.a.I_p_protocol) as ip_protocol,
    JSON_QUERY_ARRAY(gcf.a.ports) AS ports,
    pr.range_start,
    pr.range_end,
    pr.single_port
FROM combined AS gcf
LEFT JOIN (
        SELECT project_id, id, range_start, range_end, single_port
        FROM
            (
                SELECT
                    project_id, id,
                    SPLIT(p, '-')[0] AS range_start,
                    SPLIT(p, '-')[1] AS range_end,
                    NULL AS single_port
                FROM ( SELECT project_id, id, JSON_VALUE(ports) AS p
                    FROM combined,
                    UNNEST(JSON_QUERY_ARRAY(a.ports)) AS ports
                    ) AS f
                WHERE REGEXP_CONTAINS(p, r'^[0-9]+(-[0-9]+)$')
                UNION all
                SELECT project_id, id, NULL AS range_start, NULL AS range_end, p AS single_port
                FROM ( SELECT project_id, id, JSON_VALUE(ports) AS p
                    FROM combined,
                    UNNEST(JSON_QUERY_ARRAY(a.ports)) AS ports
                    ) AS f
                WHERE REGEXP_CONTAINS(p, r'^[0-9]*$')) AS s
    ) AS pr
    ON gcf.project_id = pr.project_id AND gcf.id = pr.id
)
select distinct
                name                                                                   AS resource_id, 
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that SSH access is restricted from the internet (Automated)' AS title,
                project_id                                                                AS project_id,
                CASE
           WHEN
                       direction = 'INGRESS'
                   AND (ip_protocol = 'tcp'
                   OR ip_protocol = 'all')
                   AND '0.0.0.0/0' in UNNEST(source_ranges)
                   AND (22 BETWEEN CAST(range_start AS INT64) AND CAST(range_end AS INT64)
                   OR '22' = single_port
                   OR ARRAY_LENGTH(ports) = 0
                   OR ports IS NULL)
               THEN 'fail'
           ELSE 'pass'
           END AS status
    FROM gcp_firewall_allowed_rules
{% endmacro %}