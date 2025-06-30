# FedRAMP 20x DBT Models 

These DBT models represent the evaluations Confluent is using to 
assess compliance with the current FedRAMP KSIs.

## Controls / Checks 

### KSI-CED
A secure cloud service provider will continuously educate their employees on cybersecurity measures, testing them regularly to ensure their knowledge is satisfactory.

> Not Implemented 

### KSI-CMT
A secure cloud service provider will ensure that all system changes are properly documented and configuration baselines are updated accordingly

| Framework  | Check ID | Title                                                              | Description                                                                     |
|------------|----------|--------------------------------------------------------------------|---------------------------------------------------------------------------------|
| KSI-CMT-01 | 1.0      | Cloudtrail should emit change logs to S3 for review | Verify that each AWS account has a CloudTrail log shipping to S3                | 
| KSI-CMT-02 | 1.0      | Kubernetes images should use an immutable registry | Verify all Kubernetes images use an immutable, organization managed registry    | 
| KSI-CMT-02 | 1.1      | AWS Resources should be managed by Infrastructure as Code | Verify that specific types of cloud resources have appropriate IAC tags present | 
| KSI-CMT-03 | N/A | Not Implemented |                                                                                 | 
| KSI-CMT-04 | N/A | Not Implemented |                                                                                 | 
| KSI-CMT-05 | N/A | Not Implemented |                                                                                 | 

### KSI-CNA
A secure cloud service offering will use cloud native architecture and design principles to enforce and enhance the Confidentiality, Integrity and Availability of the system.

| Framework  | Check ID | Title                                                                        | Description                                                                                                        |
|------------|----------|------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| KSI-CNA-01 | 1.0      | Ensure that public access is not given to RDS Instance (Automated)           | Check that all RDS instances have `publicly_accessible = false`                                                    | 
| KSI-CNA-01 | 1.1      | The VPC default security group should not allow inbound and outbound traffic | Check that default security groups have empty `ip_permissions` and `ip_permissions_egress`                         | 
| KSI-CNA-01 | 1.2      | Ensure that ALB restricts access to limited port ranges                      | Check the ALB security groups have either IP, or port range restrictions on traffic                                |
| KSI-CNA-02 | 1.0      | Security groups should not allow 0.0.0.0/0 ingress                           | Check that all security groups have either IP, or port range restrictions on ingress traffic                       | 
| KSI-CNA-02 | 1.1      | Security groups should not allow 0.0.0.0/0 egress                            | Check that all security groups have either IP, or port range restrictions on egress traffic                        | 
| KSI-CNA-02 | 1.2      | Network ACLs should not allow 0.0.0.0/0 ingress                              | Check that all Network ACLs have either IP, or port range restrictions on ingress traffic                          | 
| KSI-CNA-02 | 1.3      | Network ACLs should not allow 0.0.0.0/0 egress                               | Check that all Network ACLs have either IP, or port range restrictions on egress traffic                           | 
| KSI-CNA-03 | 1.0      | Security groups should not allow 0.0.0.0/0 ingress                           | Check that all security groups have either IP, or port range restrictions on ingress traffic                       | 
| KSI-CNA-03 | 1.1      | Security groups should not allow 0.0.0.0/0 egress                            | Check that all security groups have either IP, or port range restrictions on egress traffic                        | 
| KSI-CNA-03 | 1.2      | Network ACLs should not allow 0.0.0.0/0 ingress                              | Check that all Network ACLs have either IP, or port range restrictions on ingress traffic                          | 
| KSI-CNA-03 | 1.3      | Network ACLs should not allow 0.0.0.0/0 egress                               | Check that all Network ACLs have either IP, or port range restrictions on egress traffic                           | 
| KSI-CNA-04| 1.0      | Kubernetes images should use versioned tags instead of named aliases         | Check that all kubernetes images are not using string identifiers, but version-like tags                           |
| KSI-CNA-04| 1.1      | Kubernetes workloads should be immutable                                     | Ensure that all Kubernetes workloads are using one of the specified configuration management tools based on labels |
| KSI-CNA-04| 1.2      | Kubernetes images should use an internal registry                            | Check that all running Kubernetes workloads are using an image from one of the organization's internal registries  |
| KSI-CNA-05 | 1.0      | No-op: Shield provided by AWS GovCloud                                       |                                                                                                                    | 
| KSI-CNA-06 | 1.0      | VPCs should have subnets in multiple availability zones                      | For each VPC, verify that the sum of its subnets spans more than 1 availability zone                               | 
| KSI-CNA-06 | 1.1      | EKS Clusters should have node groups in multiple availability zones          | For each EKS cluster, ensure that the sum of its node groups span more than 1 availability zone                    | 
| KSI-CNA-07 | N/A | Not Implemented                                                              |                                                                                                                    | 

### KSI-IAM
A secure cloud service offering will protect user data, control access, and apply zero trust principles

| Framework  | Check ID | Title                                                              | Description                                                                                           |
|------------|----------|--------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| KSI-IAM-01 | 1.0 | Users require Multi Factor Authentication to sign in | Ensure that all Okta users have an `okta_policies` record attached requiring MFA for signing in       |
| KSI-IAM-01 | 1.1 | Applications should require Multi Factor Authentication | Ensure Okta application have `okta_policies` record attached requiring phishing-resistant MFA         | 
| KSI-IAM-02 | 1.0 | User authentication requires strong passwords | Ensure `okta_policies` enforce the configured password complexity requirements for users              | 
| KSI-IAM-03 | 1.0 | Service Accounts require secure authentication | Verify `okta_policies` require the configured password complexity requirements for service accounts   | 
| KSI-IAM-04 | 1.0 | AWS Root Accounts should not have active access credentials | For each accounts root user, verify that `access_key1_active` and `access_key2_active` are both false |
| KSI-IAM-05 | N/A | Not Implemented |                                                                                                       |
| KSI-IAM-06 | N/A | Not Implemented |                                                                                                       |

### KSI-INR
A secure cloud service offering will document, report, and analyze security incidents to ensure regulatory compliance and continuous security improvement.

> Not Implemented

### KSI-MLA
A secure cloud service offering will monitor, log, and audit all important events, activity, and changes

| Framework  | Check ID | Title                                                              | Description                                                                               |
|------------|----------|--------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| KSI-MLA-01 | 1.0 | Ensure CloudTrail is enabled in all regions |                                                                                           | 
| KSI-MLA-01 | 1.1 | Ensure that Object-level logging for write events is enabled for S3 bucket |                                                                                           | 
| KSI-MLA-01 | 1.2 | Ensure that Object-level logging for read events is enabled for S3 bucket |                                                                                           | 
 | KSI-MLA-01 | 1.3 | VPC flow logging should be enabled in all VPCs | Verify each `aws_ec2_vpcs` have a matching `aws_ec2_flow_logs` record                     | 
| KSI-MLA-02 | N/A | Not Implemented |                                                                                           |
| KSI-MLA-03 | 1.0 | EC2 instances should be scanned by Inspector | Verify each `aws_ec2_instance` has a matching `aws_inspector2_covered_resources` object   | 
| KSI-MLA-03 | 1.1 | Inspector vulnerabilities should be resolved within SLA | Verify all `aws_inspector2_findings` are marked as resolved, or within the configured SLA | 
| KSI-MLA-04 | N/A | Not Implemented |                                                                                           |
| KSI-MLA-05 | N/A | Not Implemented |                                                                                           |
| KSI-MLA-06 | N/A | Not Implemented |                                                                                           |


### KSI-PIY
A secure cloud service offering will have intentional, organized, universal guidance for how every information resource, including personnel, is secured

| Framework  | Check ID | Title                                                              | Description                                                                                |
|------------|----------|--------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| KSI-PIY-01 | 1.0 | Asset Inventories should be up to date | Check that all of this project's asset inventory models have been ran in the last 24 hours | 
| KSI-PIY-02 | N/A | Not Implemented |                                                                                            |
| KSI-PIY-03 | N/A | Not Implemented |                                                                                            |
| KSI-PIY-04 | N/A | Not Implemented |                                                                                            |
| KSI-PIY-05 | N/A | Not Implemented |                                                                                            |
| KSI-PIY-06 | N/A | Not Implemented |                                                                                            |
| KSI-PIY-07 | N/A | Not Implemented |                                                                                            |

### KSI-RPL
A secure cloud service offering will define, maintain, and test incident response plan(s) and recovery capabilities to ensure minimal service disruption and data loss during incidents and contingencies.

> Not Implemented

### KSI-SVC
A secure cloud service offering will follow FedRAMP encryption policies, continuously verify information resource integrity, and restrict access to third-party information resources.

| Framework  | Check ID | Title                                                                                 | Description                                                                              |
|------------|----------|---------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|
| KSI-SVC-01 | N/A      | Not Implemented                                                                       |                                                                                          |
| KSI-SVC-02 | 1.0      | Application Load Balancers should have an acceptable TLS policy                       |                                                                                          |
| KSI-SVC-02 | 1.1      | Application Load Balancer should be configured to redirect all HTTP requests to HTTPS | Check that each HTTP listener on an ALB redirects to one of the HTTPs ports              |
| KSI-SVC-03 | 1.0      | EBS Volumes should be encrypted at rest                                               | Verify all `aws_ec2_ebs_volumes` have `encrypted = true`                                 |
| KSI-SVC-03 | 1.1      | RDS Instances should be encrypted at rest                                             | Verify all `aws_rds_instances` have `storage_encrypted = true`                           |
| KSI-SVC-03 | 1.2      | S3 Buckets should be encrypted at rest                                                                                      | Verify all `aws_s3_buckets` have not-null `apply_server_side_encryption_by_default`      |
| KSI-SVC-03 | 1.3      | Elasticache Clusters should be encrypted at rest                                               | Verify all `aws_elasticache_clusters` have `at_rest_encryption_enabled = true`           |
| KSI-SVC-03 | 1.4      | Elasticache Replication Groups should be encrypted at rest                                              | Verify all `aws_elasticache_replication_groups` have `at_rest_encryption_enabled = true` |
| KSI-SVC-04 | N/A      | Not Implemented                                                                       |                                                                                          |
| KSI-SVC-05 | N/A      | Not Implemented                                                                       |                                                                                          |
| KSI-SVC-06 | N/A      | Ensure rotation for customer created custom master keys is enabled                                                                       | Verify all customer managed `aws_kms_keys` have `key_rotation_enabled = true`            |
| KSI-SVC-07 | N/A      | Not Implemented                                                                       |                                                                                          |

### KSI-TPR
A secure cloud service offering will understand, monitor, and manage supply chain risks from third-party information resources.

| Framework  | Check ID | Title                                                                                 | Description |
|------------|----------|---------------------------------------------------------------------------------------|-------------|
| KSI-TPR-01 | N/A      | Not Implemented | | 
| KSI-TPR-02 | 1.0      | Vendors should have FedRAMP authorization | | 
