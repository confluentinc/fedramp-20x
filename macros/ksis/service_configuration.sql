{% macro service_configuration() %}
-- KSI-SVC: Service Configuration
-- KSI-SVC-01: Implement improvements based on persistent evaluation of information resources for opportunities to improve security.
{{ jira_tickets_created_for_security_configuration_updates('KSI-SVC-01', '1.0') }}
    {{ union() }}

-- KSI-SVC-02: Encrypt or otherwise secure network traffic.
{{ alb_should_have_acceptable_tls_policy('KSI-SVC-02', '1.0')}}
    {{ union() }}
{{ alb_should_redirect_plaintext_ports('KSI-SVC-02', '1.1')}}
    {{ union() }}
({{ organization_policies_should_require_fips_compliant_load_balancers('KSI-SVC-02', '1.2')}})
    {{ union() }}
({{ s3_buckets_should_require_secure_transport('KSI-SVC-02', '1.3')}})
    {{ union() }}
({{ rds_instances_should_force_ssl('KSI-SVC-02', '1.4') }})
    {{ union() }}

-- KSI-SVC-04: Manage configuration of machine-based information resources using automation.
({{ aws_resources_should_be_managed_by_iac('KSI-SVC-04', '1.0') }})
    {{ union() }}
({{ k8s_workloads_should_be_immutable('KSI-SVC-04', '1.1') }})
    {{ union() }}

-- KSI-SVC-05: Use cryptographic methods to validate the integrity of machine-based information resources.
({{ rds_instances_should_use_customer_managed_kms_keys('KSI-SVC-05', '1.0') }})
    {{ union() }}
({{ s3_buckets_should_be_encrypted_at_rest('KSI-SVC-05', '1.1') }})
    {{ union() }}

-- KSI-SVC-06: Automate management, protection, and regular rotation of digital keys, certificates, and other secrets.
({{ aws_cisv3_mapping('KSI-SVC-06', '1.0', '3.6') }}) -- Ensure Key rotation is enabled for all customer managed KMS keys
    {{ union() }}
({{ rds_instances_should_use_customer_managed_kms_keys('KSI-SVC-06', '1.1') }})
    {{ union() }}

-- KSI-SVC-07: Use a consistent, risk-informed approach for applying security patches.
({{ ec2_instances_should_use_current_generation_types('KSI-SVC-07', '1.0') }})
    {{ union() }}
({{ eks_node_groups_should_use_recent_amis('KSI-SVC-07', '1.1') }})
    {{ union() }}

-- KSI-SVC-08: Do not introduce or leave behind residual elements that could negatively affect confidentiality,
-- integrity, or availability of federal customer data during operations.
({{ unattached_ebs_volumes('KSI-SVC-08', '1.0') }})
    {{ union() }}
({{ stopped_instances_should_be_terminated('KSI-SVC-08', '1.1') }})
    {{ union() }}
({{ unused_elastic_ips_should_be_released('KSI-SVC-08', '1.2') }})
    {{ union() }}
({{ unused_security_groups_should_be_removed('KSI-SVC-08', '1.3') }})
    {{ union() }}
({{ unused_load_balancers_should_be_removed('KSI-SVC-08', '1.4') }})
    {{ union() }}
({{ empty_target_groups_should_be_removed('KSI-SVC-08', '1.5') }})
    {{ union() }}
({{ unused_iam_roles_should_be_removed('KSI-SVC-08', '1.6') }})
    {{ union() }}
({{ unattached_gcp_disks_should_be_removed('KSI-SVC-08', '1.7') }})
    {{ union() }}
({{ unused_gcp_static_ips_should_be_released('KSI-SVC-08', '1.8') }})
    {{ union() }}
({{ orphaned_pvcs_should_be_removed('KSI-SVC-08', '1.9') }})
    {{ union() }}

-- KSI-SVC-09: Persistently validate the authenticity and integrity of communications between machine-based information
-- resources using automation.

-- KSI-SVC-10: Remove unwanted federal customer data promptly when requested by an agency in alignment with customer
-- agreements, including from backups if appropriate; this typically applies when a customer spills information or when a customer seeks to remove information from a service due to a change in usage.
({{ s3_buckets_should_have_lifecycle_policies('KSI-SVC-10', '1.0') }})
    {{ union() }}
({{ ebs_snapshots_should_have_retention_tags('KSI-SVC-10', '1.1') }})

{% endmacro %}

