# Introduction

This document represents Confluent’s draft submission for the FedRAMP 20X Phase One pilot. Please note that the contents of this document are subject to frequent updates as we work toward the final submission.

Furthermore, please be aware that this documentation is not currently applicable to our customers or our commercial products, Confluent Platform and Confluent Cloud.

## Summary of the Cloud Service Provider and Cloud Service Offering 

Confluent Cloud for Government (CCG) Software-as-a-Service (SaaS) is a fully managed, cloud-native Kafka service for connecting and processing data using a cloud computing environment. It enables its customers to focus on business needs instead of managing the underlying infrastructure supporting their Kafka instances(s). It is available to public, federal, state, local and tribal governments, as well as research institutions, federal contractors, government contractors, etc.

The CCG offering is comprised of two components – the Cloud Control Plane and Data Plane (Kafka clusters). The Cloud Control Plane is hosted in Amazon Web Services (AWS) GovCloud and Google Cloud Platform (GCP) and is used by customers to select and deploy their managed Kafka resources to a Satellite Cluster. The Satellite Cluster consists of one or many Kubernetes nodes running Kafka, with the one or many availability zones (AZs) deployed based on options selected by the customer. A customer can choose to deploy a Satellite Cluster to AWS GovCloud. The Control Plane is used to manage resources in Satellite Clusters using the Control Pipeline. All customer data is retained in Satellite Clusters and no customer data from the Satellite Clusters is sent to the Control Plane. 

CCG has undergone a comprehensive evaluation against the complete set of FedRAMP Moderate requirements and has received a recommendation for authorization from our Third Party Assessment Organization (3PAO). Furthermore, CCG has attained FedRAMP Ready status.

## Rationale for the approach used to generate the submissions

Confluent's approach for generating the submission is built using a mixture of 3rd party vendors, and open source tooling. The aggregation and analysis of our cloud configurations and other vendor data are managed in 3 distinct steps. 

![Data ETL diagram showing various sources that evidence is gathered from by CloudQuery, which feeds into DBT macros and models, and ultimately into a report](/assets/data-etl.png)

### 1. Data ETL

Confluent is leveraging a vendor, [CloudQuery](https://www.cloudquery.io/), for extracting data from the myriad of systems comprising its FedRAMP offering. They provide a framework and SDK for configuring repetitive syncs of data into a central data warehouse (which currently is BigQuery). To satisfy the 20x program, we are pulling data from the following sources:

- AWS Accounts 
- GCP Projects
- Kubernetes Clusters
- Okta IDP 
- Confluence / JIRA  
- Github

The various data from these endpoints are stored in individual BigQuery tables, which contain normalized data structures and references that we can evaluate against. The data will be pulled at various frequencies to satisfy control requirements.

> [!NOTE]
> CloudQuery is self-hosted in our air-gapped environment to maintain FedRAMP compliance

### 2. Control Evaluation 

To ensure compliance with required controls, Confluent is using DBT on top of the BigQuery data warehouse. Controls, specifications, and other validations of the KSIs are mapped to macros, and the model is run in its entirety against the previously aggregated data. These DBT models can be run at any time, to generate an updated report of CCG's compliance, based on the latest set of data stored in our warehouse.

#### Example Control 1: Encryption At Rest 

Based on the dataset compiled from our CSP, we can generate queries to check for encryption on various data storage systems. 

1. Ensure all S3 buckets have encryption enabled

```
{% macro verify_s3_encryption() %}
select
    'KSI-004' as ksi_id,
    'SC_28' as control_id,
    'S3_ENCRYPTION' as check_name,
    'S3 buckets are encrypted' as name,
    buckets.arn as identifier,
    case when encrules.apply_server_side_encryption_by_default IS NOT NULL
        then 'pass'
        else 'fail'
    end as status
from aws_s3_buckets buckets
left join aws_s3_bucket_encryption_rules encrules
on buckets.arn = encrules.bucket_arn
{% endmacro %}
```

2. Ensure all RDS clusters use encrypted storage

```
{% macro verify_rds_encryption() %}
select
    'KSI-004' as ksi_id,
    'SC_28' as control_id,
    'RDS_ENCRYPTION' as check_name,
    'RDS Clusters are encrypted' as check,
    arn as identifier,
    null as metadata,
    case when storage_encrypted = true
        then 'pass'
        else 'fail'
    end as status
from aws_rds_instances
{% endmacro %}
```

3. Ensure all EBS volumes are encrypted
```
{% macro verify_ebs_encryption() %}
select
    'KSI-004' as ksi_id,
    'SC_28' as control_id,
    'EBS_ENCRYPTION' as check_name,
    arn as identifier,
    null as metadata,
    case when encrypted = true
        then 'pass'
        else 'fail'
    end as status
from aws_ec2_ebs_volumes
{% endmacro %}
```
This example is not meant to be exhaustive, but shows how Confluent is able to extract specific datapoints from our aggregated data, and verify that any respective controls are adhered to

#### Building the Model

After mapping any required controls or compliance indicators to individual queries, we then build a DBT model representing those in summation, and execute that model against the entirety of our dataset 
```
with
    aggregated as (
    {{ verify_s3_encryption }}
    UNION ALL
    {{ verify_rds_encryption }}
    UNION ALL
    {{ verify_ebs_encryption }}
    {{...repeat for all other controls...}}
    )
select
    CURRENT_TIMESTAMP() as timestamp,
    aggregated.*
from aggregated
```
Running this model provides an end-to-end compliance check of our services, configurations, access controls, etc, and stores that in a materialized view for further processing

We can then generate a sum evaluation for any group of controls against that materialized view
```
SELECT ksi_id, control_id, check_name, status, count(status) as count 
FROM {{ dbt_table }}
GROUP by ksi_id, control_id, check_name, status

This will output a result similar to below, indicating which checks were ran, and the total pass / fail counts for that control

| ksi_id.    | control_id | check_name     | check                      | status | count |
|------------|------------|----------------|----------------------------|--------|-------|
| KSI-004    | SC-28      | S3_ENCRYPTION  | S3 buckets are encrypted   | pass   | 5     |
| KSI-004    | SC-28      | S3_ENCRYPTION  | S3 buckets are encrypted   | fail   | 1     |
| KSI-004    | SC-28      | EBS_ENCRYPTION | EBS Volumes are encrypted  | pass   | 32    |
| KSI-004    | SC-28      | RDS_ENCRYPTION | RDS Clusters are encrypted | pass   | 4     |
```

The results from this query are used to generate the machine-readable assessment reports as needed.

#### Example Control 2: Unsuccessful Login Attempts 
```
{% macro verify_okta_lockout() %}
{% set max_login_attempts = 3 %} -- Require lockout after 3 attempts
  
select
    'KSI-002' as ksi_id,
    'AC-7' as control_id,
    'UNSUCCESSFUL_LOGIN_ATTEMPS' as check_name,
    'Lock accounts after {{ max_login_attempts }} attempts' as check,
    id as identifier,
    null as metadata,
    case
        when CAST(
          JSON_EXTRACT_SCALAR(
            additional_properties, 
           '$.settings.password.lockout.maxAttempts'
          ) as INT64
        ) >= {{ max_login_attemps }}
        then 'pass'
        else 'fail'
    end as status
from okta_policies  
where type = "PASSWORD"
{% endmacro %}
```
### 3. Reporting

Once DBT creates materialized views with the results of control evaluations, that compliance data can be translated to effectively any format. Currently, we are converting it to the respective machine-readable JSON document, and storing these generated reports in long term storage. This reporting layer could be later replaced or expanded to include other languages, or other standardized formats, such as OSCAL.

## Methodology for Continuous Reporting

The data pipeline outlined above allows Confluent to easily run continuous compliance checks on the environment. The data is being aggregated by CloudQuery, automatically, at a defined interval (currently: daily). These generate day-partitioned tables in BigQuery which represent the currently deployed state of our entire system. The DBT models are then configured to run on a similarly configured schedule, which generates materialized views representing the current compliance stature. These tables are then exported to a machine-readable format, and placed in long term storage for review / retrieval.

### Third Party Assessment Organization (3PAO) Engagement

We have contracted with the 3PAO, Fortreum, to be engaged with our final pilot submissions in the future.   

## Machine Readable Assessment File 

As stated in the **Reporting** section, we are able to generate a machine readable assessment in any format. Currently, we are using OSCAL format for a Security Assessment Report (SAR), but this maybe subject to change overtime as we gather requirements of what agencies and customers may need from a machine readable assessment file. 



