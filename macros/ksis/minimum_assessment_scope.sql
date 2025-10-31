{% macro minimum_assessment_scope() %}
-- FRR-MAS-01: Providers MUST identify a set of information resources to assess for FedRAMP authorization that
-- includes all information resources that are likely to handle federal information or likely to impact the
-- confidentiality, integrity, or availability of federal information handled by the cloud service offering.
({{ verify_syncs_meet_success_threshold('FRR-MAS-01', '1.0') }})
    {{ union() }}
({{ verify_coverage_of_synced_sources('FRR-MAS-01', '1.1') }})

{% endmacro %}

