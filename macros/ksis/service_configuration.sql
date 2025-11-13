{% macro service_configuration() %}
-- KSI-SVC: Service Configuration
-- KSI-SVC-01: Continuously evaluate machine-based information resources for opportunities to improve security
{{ jira_tickets_created_for_security_configuration_updates('KSI-SVC-01', '1.0') }}
    {{ union() }}

-- KSI-SVC-02: Encrypt or otherwise secure network traffic
{{ alb_should_have_acceptable_tls_policy('KSI-SVC-02', '1.0')}}
    {{ union() }}
{{ alb_should_redirect_plaintext_ports('KSI-SVC-02', '1.1')}}
    {{ union() }}
({{ organization_policies_should_require_fips_compliant_load_balancers('KSI-SVC-02', '1.2')}})
    {{ union() }}
({{ s3_buckets_should_require_secure_transport('KSI-SVC-02', '1.3')}})
    {{ union() }}

-- KSI-SVC-03: Encrypt information at rest by default
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

-- KSI-SVC-04: Manage configuration of machine-based information resources using automation
({{ aws_resources_should_be_managed_by_iac('KSI-SVC-04', '1.0') }})
    {{ union() }}
({{ k8s_workloads_should_be_immutable('KSI-SVC-04', '1.1') }})
    {{ union() }}

-- KSI-SVC-05: Use cryptographic methods to validate the integrity of machine-based information resources
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

-- KSI-SVC-08: Ensure that changes do not introduce or leave behind residual elements that could negatively
-- affect confidentiality, integrity, or availability of information resources.
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

-- KSI-SVC-09: Use mechanisms that continuously validate the authenticity and integrity of communications between information resources.
-- KSI-SVC-10: Remove unwanted information promptly, including from backups if appropriate.

{% endmacro %}

