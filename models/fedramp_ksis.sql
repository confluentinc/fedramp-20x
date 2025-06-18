with
    aggregated as (
        -- KSI-AUD-01: Enable and configure detailed audit logging.
        -- KSI-AUD-02: Protect audit logs from tampering and deletion.
        -- KSI-AUD-03: Monitor audit logs for suspicious activity.
        -- KSI-AUD-04: Retain audit logs according to requirements.

        -- KSI-CMT-01: Use infrastructure-as-code to deploy and manage infrastructure.

        -- KSI-CMT-02: Track and document configuration changes.
        ({{ organization_cloudtrail_should_emit_events_to_s3('KSI-CMT-02', '1.0') }})
            {{ union() }}

        -- KSI-CMT-03: Review and validate configuration changes.

        -- KSI-CMT-04: Use configuration management for all system components.
        ({{ k8s_images_should_use_immutable_registry('KSI-CMT-04', '1.0')}})
            {{ union() }}
        ({{ aws_resources_should_be_managed_by_iac('KSI-CMT-04', '1.1') }})
            {{ union() }}

        -- KSI-CNA-01: Configure ALL information resources to limit inbound and outbound traffic
        -- KSI-CNA-02: Design systems to minimize the attack surface and minimize lateral movement if compromised
        -- KSI-CNA-03: Use logical networking and related capabilities to enforce traffic flow controls

        -- KSI-CNA-04: Use immutable infrastructure with strictly defined functionality and privileges by default
        ({{ k8s_images_should_use_immutable_tags('KSI-CNA-04', '1.0') }})
            {{ union() }}
        ({{ k8s_workloads_should_be_immutable('KSI-CNA-04', '1.1') }})
            {{ union() }}
        ({{ k8s_images_should_use_internal_registry('KSI-CNA-04', '1.2') }})
            {{ union() }}

        -- KSI-CNA-05: Have denial of service protection

        -- KSI-CNA-06: Design systems for high availability and rapid recovery
        ({{ vpcs_should_have_subnets_in_multiple_azs('KSI-CNA-06', '1.0')}})
            {{ union() }}
        ({{ eks_cluster_node_groups_should_span_multiple_azs('KSI-CNA-06', '1.1') }})
            {{ union() }}

        -- KSI-CNA-07: Ensure cloud-native information resources are implemented based on host provider's best practices and documented guidance.
        ({{ evaluate_cis_compliance('KSI-CNA-07', '1.0') }})
            {{ union() }}

        -- KSI-IAM-01: Use centrally managed authentication and authorization.

        -- KSI-IAM-02: Control access based on roles and cloud-native functions.

        -- KSI-IAM-03: Enforce minimum password and authentication requirements.
        ({{ okta_users_require_mfa('KSI-IAM-03', '1.0')}})
            {{ union() }}
        ({{ okta_apps_should_require_multifactor_authentication('KSI-IAM-03', '1.1') }})
            {{ union() }}
        ({{ okta_users_require_strong_password('KSI-IAM-03', '1.2') }})
            {{ union() }}
        ({{ okta_service_accounts_have_secure_authentication('KSI-IAM-03', '1.3') }})
            {{ union() }}

        -- KSI-IAM-04: Manage and protect privileged accounts.
        ({{ iam_root_user_has_no_access_keys('KSI-IAM-04', '1.0') }})
            {{ union() }}
        -- KSI-IAM-05: Regularly review and validate access.

        -- KSI-INC-01: Maintain incident response procedures.
        -- KSI-INC-02: Report security incidents promptly.
        -- KSI-INC-03: Document and track incident responses.
        -- KSI-INC-04: Review and update incident response procedures.

        -- KSI-MON-01: Monitor system performance and availability.
        -- KSI-MON-02: Monitor security events and alerts.
        -- KSI-MON-03: Use automated monitoring tools.
        -- KSI-MON-04: Regularly review monitoring data.

        -- KSI-SVC-01: Harden and review network and system configurations

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

        -- KSI-SVC-04: Manage configuration centrally

        -- KSI-SVC-05: Enforce system and information resource integrity through cryptographic means
        ({{ k8s_clusters_should_have_enforcement_webhooks('KSI-SVC-05', '1.0') }})
            {{ union() }}
        ({{ k8s_has_image_enforcement_policies('KSI-SVC-05', '1.1') }})
            {{ union() }}
        ({{ k8s_image_enforcement_policies_should_not_ignore_failures('KSI-SVC-05', '1.2') }})
            {{ union() }}

        -- KSI-SVC-06: Use automated key management systems to manage, protect, and regularly rotate digital keys and certificates.
        ({{ aws_cisv3_mapping('KSI-SVC-06', '1.0', '3.6') }}) -- Ensure Key rotation is enabled for all customer managed KMS keys
            {{ union() }}

        -- KSI-SVC-07: Use a consistent, risk-informed approach for applying security patches

        -- KSI-VLN-01: Regularly scan for vulnerabilities.
        ({{ ec2_instances_should_be_scanned_by_inspector('KSI-VLN-01', '1.0')}})
            {{ union() }}

        -- KSI-VLN-02: Track and remediate identified vulnerabilities.
        ({{ inspector_vulnerabilities_should_be_resolved_in_sla('KSI-VLN-02', '1.1') }})
            {{ union() }}

        -- KSI-VLN-03: Use automated vulnerability scanning tools.
        ({{ ec2_instances_should_be_scanned_by_inspector('KSI-VLN-01', '1.0')}})
            {{ union() }}

        -- KSI-VLN-04: Maintain vulnerability management program.
    )
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated
