with
    aggregated as (
        ({{ k8s_container_images("k8s_apps_daemon_sets") }})
            {{ union() }}
        ({{ k8s_container_images("k8s_apps_deployments") }})
            {{ union() }}
        ({{ k8s_container_images("k8s_apps_stateful_sets") }})
    )
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated