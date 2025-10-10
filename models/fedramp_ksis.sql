{% set incident_tracking_jira_project = var('incident_tracking_jira_project') %}
{% set continuous_monitoring_jira_project = var('continuous_monitoring_jira_project') %}
{% set security_jira_project = var('security_jira_project') %}

with
    aggregated as (
        -- KSI-CED-01: Ensure all employees receive security awareness training.
        -- KSI-CED-02: Require role-specific training for high risk roles, including at least roles with privileged access.
        ({{ verify_syncs_meet_success_threshold('FRR-MAS-01', '1.0') }})
            {{ union() }}
        ({{ verify_coverage_of_synced_sources('FRR-MAS-01', '1.1') }})
            {{ union() }}
        -- KSI-CMT-01: Log and monitor system modifications.
        ({{ organization_cloudtrail_should_emit_events_to_s3('KSI-CMT-01', '1.0') }})
            {{ union() }}

        -- KSI-CMT-02: Execute changes through redeployment of version controlled immutable resources rather than direct modification wherever possible.
--         TODO: k8s_images_should_use_immutable_registry can be re-enabled once required work has been completed
--         TODO: aws_resources_should_be_managed_by_iac can be re-enabled once required work has been completed

        -- KSI-CMT-03: Implement automated testing and validation of changes prior to deployment.
        -- KSI-CMT-04: Have a documented change management procedure.
        -- KSI-CMT-05: Evaluate the risk and potential impact of any change.
        ({{ jira_should_have_change_management_project('KSI-CMT-05', '1.0') }})
            {{ union() }}
        ({{ jira_change_tickets_should_be_approved('KSI-CMT-05', '1.1') }})
            {{ union() }}
        -- KSI-CNA-01: Configure ALL information resources to limit inbound and outbound traffic
        ({{ aws_cisv3_mapping('KSI-CNA-01', '1.0', '2.3.3') }}) -- RDS Should not be publicly accessible
            {{ union() }}
        ({{ aws_foundational_security_mapping('KSI-CNA-01', '1.1', 'ec2.2') }})
            {{ union() }}
        ({{ alb_security_groups_should_restrict_to_limited_ports('KSI-CNA-01', '1.2') }})
            {{ union() }}

        -- KSI-CNA-02: Design systems to minimize the attack surface and minimize lateral movement if compromised
        ({{ security_groups_should_not_have_broad_ingress('KSI-CNA-02', '1.0') }})
            {{ union() }}
        ({{ security_groups_should_not_have_broad_egress('KSI-CNA-02', '1.1') }})
            {{ union() }}
        ({{ nacls_should_not_have_broad_ingress('KSI-CNA-02', '1.2') }})
            {{ union() }}
        ({{ nacls_should_not_have_broad_egress('KSI-CNA-02', '1.3') }})
            {{ union() }}
        ({{ verify_default_vpc_unused('KSI-CNA-02', '1.4')}})
            {{ union() }}


        -- KSI-CNA-03: Use logical networking and related capabilities to enforce traffic flow controls
        ({{ security_groups_should_not_have_broad_ingress('KSI-CNA-03', '1.0') }})
            {{ union() }}
        ({{ security_groups_should_not_have_broad_egress('KSI-CNA-03', '1.1') }})
            {{ union() }}
        ({{ nacls_should_not_have_broad_ingress('KSI-CNA-03', '1.2') }})
            {{ union() }}
        ({{ nacls_should_not_have_broad_egress('KSI-CNA-03', '1.3') }})
            {{ union() }}
        ({{ verify_default_vpc_unused('KSI-CNA-03', '1.4')}})
            {{ union() }}

        -- KSI-CNA-04: Use immutable infrastructure with strictly defined functionality and privileges by default
        ({{ k8s_images_should_use_immutable_tags('KSI-CNA-04', '1.0') }})
            {{ union() }}
        ({{ k8s_workloads_should_be_immutable('KSI-CNA-04', '1.1') }})
            {{ union() }}
        ({{ k8s_images_should_use_internal_registry('KSI-CNA-04', '1.2') }})
            {{ union() }}

        -- KSI-CNA-05: Have denial of service protection
        ({{ aws_shield_included_in_govcloud('KSI-CNA-05', '1.0') }})
            {{ union() }}
        ({{ eks_control_planes_limit_inbound_ip_ranges('KSI-CNA-05', '1.1') }})
            {{ union() }}
        ({{ load_balancers_have_cloud_armor_policies('KSI-CNA-05', '1.2') }})
            {{ union() }}
        ({{ gcp_compute_clusters_should_restrict_inbound_ips('KSI-CNA-05', '1.3') }})
            {{ union() }}

        -- KSI-CNA-06: Design systems for high availability and rapid recovery
        ({{ vpcs_should_have_subnets_in_multiple_azs('KSI-CNA-06', '1.0')}})
            {{ union() }}
        ({{ eks_cluster_node_groups_should_span_multiple_azs('KSI-CNA-06', '1.1') }})
            {{ union() }}

        -- KSI-CNA-07: Ensure cloud-native information resources are implemented based on host provider's best practices and documented guidance.
        ({{ aws_cis_compliance_summary('KSI-CNA-07', '1.0') }}) -- AWS CIS v3 Compliance (Scored)
            {{ union() }}
        ({{ aws_foundational_security_summary('KSI-CNA-07', '1.1') }}) -- AWS Foundational Security (Scored)
            {{ union() }}
        ({{ gcp_cis_compliance_summary('KSI-CNA-07', '1.2') }}) -- GCP CIS v2 Compliance (Scored)
            {{ union() }}

        -- KSI-IAM-01: Enforce multi-factor authentication (MFA) using methods that are difficult to intercept or impersonate (phishing-resistant MFA) for all user authentication.
        ({{ okta_users_require_mfa('KSI-IAM-01', '1.0')}})
            {{ union() }}
        ({{ okta_apps_should_require_multifactor_authentication('KSI-IAM-01', '1.1') }})
            {{ union() }}

        -- KSI-IAM-02: Use secure passwordless methods for user authentication and authorization when feasible, otherwise enforce strong passwords with MFA.
        ({{ okta_users_require_strong_password('KSI-IAM-02', '1.0') }})
            {{ union() }}

        -- KSI-IAM-03: Enforce appropriately secure authentication methods for non-user accounts and services.
        ({{ okta_service_accounts_have_secure_authentication('KSI-IAM-03', '1.0') }})
            {{ union() }}

        -- KSI-IAM-04: Use a least-privileged, role and attribute-based, and just-in-time security authorization model for all user and non-user accounts and services.
        ({{ iam_root_user_has_no_access_keys('KSI-IAM-04', '1.0') }})
            {{ union() }}

        -- KSI-IAM-05: Design identity and access management systems that assume resources will be compromised
        ({{ okta_behavior_rules_detect_compromise('KSI-IAM-05', '1.0') }})
            {{ union() }}
        -- KSI-IAM-06: Automatically disable or otherwise secure accounts with privileged access in response to suspicious activity.

        -- KSI-INR-01: Report incidents according to FedRAMP requirements and cloud service provider policies.
        -- KSI-INR-02: Maintain a log of incidents and periodically review past incidents for patterns or vulnerabilities.
        ({{ jira_should_have_security_project('KSI-INR-02', '1.0') }})
            {{ union() }}
        ({{ jira_should_have_incident_tracking_project('KSI-INR-02', '1.1') }})
            {{ union() }}


        -- KSI-INR-03: Generate after action reports and regularly incorporate lessons learned into operations.

        -- KSI-MLA-01: Operate a Security Information and Event Management (SIEM) or similar system(s) for centralized, tamper-resistent logging of events, activities, and changes.
        ({{ aws_cisv3_mapping('KSI-MLA-01', '1.0', '3.1') }}) -- CloudTrail is enabled in all regions
            {{ union() }}
        ({{ aws_cisv3_mapping('KSI-MLA-01', '1.1', '3.8') }}) -- CloudTrail Write events are enabled
            {{ union() }}
        ({{ aws_cisv3_mapping('KSI-MLA-01', '1.2', '3.9') }}) -- CloudTrail Read events are enabled
            {{ union() }}
        ({{ aws_cisv3_mapping('KSI-MLA-01', '1.3', '3.7') }}) -- CloudTrail Read events are enabled
            {{ union() }}

        -- KSI-MLA-02: Regularly review and audit logs.
        -- KSI-MLA-03: Rapidly detect and remediate or mitigate vulnerabilities.
        ({{ ec2_instances_should_be_scanned_by_inspector('KSI-MLA-03', '1.0')}})
            {{ union() }}
        ({{ inspector_vulnerabilities_should_be_resolved_in_sla('KSI-MLA-03', '1.1') }})
            {{ union() }}

        -- KSI-MLA-04: Perform authenticated vulnerability scanning on information resources.
        -- KSI-MLA-05: Perform Infrastructure as Code and configuration evaluation and testing.
        -- KSI-MLA-06: Centrally track and prioritize the mitigation and/or remediation of identified vulnerabilities.
        ({{ jira_should_be_used_for_tracking_vulnerabilities('KSI-MLA-06', '1.0') }})
            {{ union() }}
        ({{ jira_should_have_continuous_monitoring_project('KSI-MLA-06', '1.1') }})
            {{ union() }}

        -- KSI-MLA-07: Maintain a list of information resources and event types that will be monitored, logged, and audited.
        -- KSI-MLA-08: Use a least-privileged, role and attribute-based, and just-in-time access authorization model for access to log data.
        ({{ eks_control_planes_should_use_oidc_access('KSI-MLA-08', '1.0') }})
            {{ union() }}
        ({{ iam_roles_for_engineer_access_use_saml('KSI-MLA-08', '1.1') }})
            {{ union() }}
        ({{ okta_system_logs_just_in_time_access('KSI-MLA-08', '1.2', var('logging_applications')) }})
            {{ union() }}

        -- KSI-PIY-01: Have an up-to-date information resource inventory or code defining all deployed assets, software, and services.
        ({{ asset_inventories_should_be_up_to_date('KSI-PIY-01', '1.0') }})
            {{ union() }}
        -- KSI-PIY-02: Have policies outlining the security objectives of all information resources.
        -- KSI-PIY-03: Maintain a vulnerability disclosure program.
        -- KSI-PIY-04: Build security considerations into the Software Development Lifecycle and align with CISA Secure By Design principles.
        -- KSI-PIY-05: Document methods used to evaluate information resource implementations.
        -- KSI-PIY-06: Have a dedicated staff and budget for security with executive support, commensurate with the size, complexity, scope, and risk of the service offering.
        -- KSI-PIY-07: Document risk management decisions for software supply chain security.

        -- KSI-RPL-01: Define Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO).
        ({{ rds_instances_should_have_backup_enabled('KSI-RPL-01','1.0') }})
            {{ union() }}
        ({{ s3_buckets_should_have_backup_vault_configured('KSI-RPL-01','1.1') }})
            {{ union() }}
        -- KSI-RPL-02: Develop and maintain a recovery plan that aligns with the defined recovery objectives.
        -- KSI-RPL-03: Perform system backups aligned with recovery objectives.
        ({{ rds_instances_should_have_backup_enabled('KSI-RPL-03','1.0') }})
            {{ union() }}
        ({{ s3_buckets_should_have_backup_vault_configured('KSI-RPL-03','1.1') }})
            {{ union() }}
        -- KSI-RPL-04: Regularly test the capability to recover from incidents and contingencies.

        -- KSI-SVC-01: Harden and review network and system configurations

        -- KSI-SVC-02: Encrypt or otherwise secure network traffic
        {{ alb_should_have_acceptable_tls_policy('KSI-SVC-02', '1.0')}}
            {{ union() }}
        {{ alb_should_redirect_plaintext_ports('KSI-SVC-02', '1.1')}}
            {{ union() }}
        ({{ organization_policies_should_require_fips_compliant_load_balancers('KSI-SVC-02', '1.2')}})
            {{ union() }}
        ({{ s3_buckets_should_require_secure_transport('KSI-SVC-02', '1.3')}})
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
        ({{ ebs_volumes_should_be_encrypted_by_default('KSI-SVC-03', '1.5')}})
            {{ union() }}
        ({{ organization_policies_should_block_unencrypted_ec2_instances('KSI-SVC-03', '1.6')}})
            {{ union() }}
        ({{ organization_policies_should_block_unencrypted_rds_instances('KSI-SVC-03', '1.7')}})
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

        -- KSI-TPR-01: Identify all third-party information resources .
        -- KSI-TPR-02: Regularly confirm that services handling federal information or are likely to impact the confidentiality, integrity, or availability of federal information are FedRAMP authorized and securely configured.
        ({{ vendors_should_have_fedramp_authorization('KSI-TPR-02', '1.0') }})

        -- KSI-TPR-03: Identify and prioritize mitigation of potential supply chain risks.
        -- KSI-TPR-04: Monitor third party software information resources for upstream vulnerabilities, with contractual notification requirements or active monitoring services.
    )
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated
