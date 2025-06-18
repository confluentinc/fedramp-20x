with
    aggregated as (
        -- KSI-CMT-01: Log and monitor system modifications
        ({{ organization_cloudtrail_should_emit_events_to_s3('KSI-CMT-01', '1.0') }})
            {{ union() }}

        -- KSI-CMT-02: Execute changes through redeployment of version controlled immutable resources rather than direct modification wherever possible
        ({{ k8s_images_should_use_immutable_registry('KSI-CMT-02', '1.0')}})
            {{ union() }}
        ({{ aws_resources_should_be_managed_by_iac('KSI-CMT-02', '1.1') }})
            {{ union() }}

        -- KSI-CNA-04: Use immutable infrastructure with strictly defined functionality and privileges by default
        ({{ k8s_images_should_use_immutable_tags('KSI-CNA-04', '1.0') }})
            {{ union() }}
        ({{ k8s_workloads_should_be_immutable('KSI-CNA-04', '1.1') }})
            {{ union() }}
        ({{ k8s_images_should_use_internal_registry('KSI-CNA-04', '1.2') }})
            {{ union() }}

        -- KSI-CNA-06: Design systems for high availability and rapid recovery
        ({{ vpcs_should_have_subnets_in_multiple_azs('KSI-CNA-06', '1.0')}})
            {{ union() }}
        ({{ eks_cluster_node_groups_should_span_multiple_azs('KSI-CNA-06', '1.1') }})
            {{ union() }}

        -- KSI-IAM-01: Use centrally managed authentication and authorization.


        -- KSI-IAM-02: Control access based on roles and cloud-native functions.


        -- KSI-IAM-03: Enforce minimum password and authentication requirements.
        ({{ okta_users_require_mfa('KSI-IAM-02', '1.0')}})
            {{ union() }}
        ({{ okta_apps_should_require_multifactor_authentication('KSI-IAM-01', '1.1') }})
            {{ union() }}
        ({{ okta_users_require_strong_password('KSI-IAM-02', '1.1') }})
            {{ union() }}
        ({{ okta_service_accounts_have_secure_authentication('KSI-IAM-03', '1.0') }})
            {{ union() }}

        -- KSI-IAM-04: Manage and protect privileged accounts.
        ({{ iam_root_user_has_no_access_keys('KSI-IAM-04', '1.0') }})
            {{ union() }}

        -- KSI-SVC-06: Use automated key management systems to manage, protect, and regularly rotate digital keys and certificates.
        ({{ aws_cisv3_mapping('KSI-SVC-06', '1.0', '3.6') }}) -- Ensure Key rotation is enabled for all customer managed KMS keys
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
            {{ union() }}

        -- KSI-SVC-02: Encrypt or otherwise secure network traffic
        {{ alb_should_have_acceptable_tls_policy('KSI-SVC-02', '1.0')}}
            {{ union() }}
        {{ alb_should_redirect_plaintext_ports('KSI-SVC-02', '1.1')}}
            {{ union() }}

        -- KSI-SVC-03: Encrypt all federal and sensitive information at rest
        ({{ ebs_volumes_should_be_encrypted_at_rest('KSI-SVC-03', '1.0') }})
            {{ union() }}
        ({{ rds_instances_should_be_encrypted_at_rest('KSI-SVC-03', '1.1') }})
            {{ union() }}
        ({{ s3_buckets_should_be_encrypted_at_rest('KSI-SVC-03', '1.2') }})
            {{ union() }}
        ({{ elasticache_clusters_should_be_encrypted_at_rest('KSI-SVC-03', '1.3') }})
            {{ union() }}
        ({{ elasticache_replication_groups_should_be_encrypted_at_rest('KSI-SVC-03', '1.4') }})
            {{ union() }}

        -- KSI-SVC-05: Enforce system and information resource integrity through cryptographic means
        ({{ k8s_clusters_should_have_enforcement_webhooks('KSI-SVC-04', '1.0') }})
            {{ union() }}
        ({{ k8s_has_image_enforcement_policies('KSI-SVC-04', '1.1') }})
            {{ union() }}
        ({{ k8s_image_enforcement_policies_should_not_ignore_failures('KSI-SVC-04', '1.2') }})

    )
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated
