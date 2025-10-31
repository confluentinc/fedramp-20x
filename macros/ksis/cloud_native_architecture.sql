{% macro cloud_native_architecture() %}

-- KSI-CNA: Cloud Native Architecture
-- KSI-CNA-01: Configure ALL machine-based information resources to limit inbound and outbound traffic

({{ verify_default_vpc_unused('KSI-CNA-01', '1.0')}})
    {{ union() }}
({{ verify_default_security_group_unused('KSI-CNA-01', '1.1') }})
    {{ union() }}
({{ alb_security_groups_should_restrict_to_limited_ports('KSI-CNA-01', '1.2') }})
    {{ union() }}
({{ rds_instances_have_inbound_access_restrictions('KSI-CNA-01', '1.3') }})
    {{ union() }}
({{ rds_instances_have_outbound_access_restrictions('KSI-CNA-01', '1.4') }})
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

-- KSI-CNA-05: Protect against denial of service attacks and unwanted spam
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

-- KSI-CNA-08: Use automated services to persistently assess the security posture of all services and automatically enforce secure operations.

{% endmacro %}

