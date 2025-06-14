with
    aggregated as (

        -- KSI-SVC-02: Encrypt or otherwise secure network traffic
        {{ alb_should_have_acceptable_tls_policy('KSI-SVC-02', '1.0')}}
            {{ union() }}
        {{ alb_should_redirect_plaintext_ports('KSI-SVC-02', '1.1')}}

        -- KSI-SVC-03: Encrypt all federal and sensitive information at rest
        ({{ ebs_volumes_should_be_encrypted_at_rest('KSI_SC', '1.0') }})
            {{ union() }}
        ({{ rds_clusters_should_be_encrypted_at_rest('KSI_SC', '1.1') }})
            {{ union() }}
        ({{ s3_buckets_should_be_encrypted_at_rest('KSI_SC', '1.2') }})
            {{ union() }}
        ({{ elasticache_clusters_should_be_encrypted_at_rest('KSI_SC', '1.3') }})
            {{ union() }}
        ({{ elasticache_replication_groups_should_be_encrypted_at_rest('KSI_SC', '1.4') }})
            {{ union() }}

        -- KSI-MLA-04: Perform authenticated vulnerability scanning on information resources
        ({{ ec2_instances_should_be_scanned_by_inspector('KSI-MLA-04', '1.0')}})
{{ union() }}
        ({{ inspector_vulnerabilities_should_be_resolved_in_sla('KSI-MLA-04', '1.1') }})
{{ union() }}
        -- KSI-RPL-03: Perform system backups aligned with recovery objectives
({{ rds_instances_should_have_backups_configured('KSI-RPL-03', '1.0') }})
{{ union() }}
({{ rds_instances_should_have_backup_vault_configured('KSI-RPL-03', '1.1') }})
{{ union() }}
({{ s3_buckets_should_have_backup_vault_configured('KSI-RPL-03', '1.2') }})
    )
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated