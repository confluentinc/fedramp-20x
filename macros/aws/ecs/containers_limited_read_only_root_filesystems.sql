{% macro containers_limited_read_only_root_filesystems(framework, check_id) %}
  {{ return(adapter.dispatch('containers_limited_read_only_root_filesystems')(framework, check_id)) }}
{% endmacro %}

{% macro default__containers_limited_read_only_root_filesystems(framework, check_id) %}{% endmacro %}

{% macro bigquery__containers_limited_read_only_root_filesystems(framework, check_id) %}
with latest_revisions as (
    SELECT
        REGEXP_REPLACE(arn, ':[^:]+$', '') AS versionless_arn,
        account_id,
        max(revision) AS latest_revision
    FROM
        {{ full_table_name("aws_ecs_task_definitions") }}
    WHERE
        status = 'ACTIVE'
    AND {{ partition_filter() }}
    GROUP BY
        versionless_arn,
        account_id
),
flat_containers as (
    SELECT
        t.arn,
        t.account_id,
        CASE
            WHEN CAST(JSON_VALUE(container_definition.readonlyRootFilesystem) AS BOOL) = FALSE
            OR JSON_VALUE(container_definition.readonlyRootFilesystem) IS NULL THEN 1
            ELSE 0
        END AS status,
        lr.latest_revision
    FROM
        latest_revisions lr
    JOIN
        {{ full_table_name("aws_ecs_task_definitions") }} t
    ON
        CONCAT(lr.versionless_arn, ':', latest_revision) = t.arn
        AND lr.account_id = t.account_id
        AND lr.latest_revision = t.revision,
        UNNEST(JSON_QUERY_ARRAY(t.container_definitions)) AS container_definition
    WHERE
    t.status = 'ACTIVE'
)
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'ECS containers should be limited to read-only access to root filesystems' as title,
    account_id,
    arn,
    CASE
        WHEN max(status) OVER (PARTITION BY arn) = 1 THEN 'fail'
        ELSE 'pass'
        END as status
from
    flat_containers
{% endmacro %}
