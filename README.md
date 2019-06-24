# clark
Consul cluster using terraform for Clark

Project detail
-------------

Case
-----
1. We use AWS for hosting our solution
2. For operating our infrastructure we need a HA Consul cluster distributed over at least 3
availability zones
3. The setup and maintenance should be fully automated
4. Consul instances should discover themselves using DNS

Task
-----
Automate the deployment and management of a Consul cluster
- Choose a concept/tool to automate the deployment and provisioning of the needed
AWS resources and servers
- Implement and test your solution
- Provide us with a git repository showing not only the result, but also the way you’ve
taken to implement your solution


Solution
--------

1. Enable private DNS.
    Created a VPC with cutom DHCP options set and a Lambda to add and remove record set in Rote53.
2. Created a packer image with Consul binaries deployed.
3. A Consul cluster was created with 3 nodes where nodes will identify each other using EC2 instance tags.
4. Since the instances were registerd in Route53 through Lambda DNS resolution is happening fine.
5. Backup script was implemented to take backup in Consul Leader node and uploaded to S3 bucket.
6. S3 bucket has a policy implemented for object recycle.
7. Deployment auto mation can be done using Bamboo or Jenkin as a usual terraform script.

Pending / Issues identified
---------------------------

1. When one node gets terminated the cluster is recovering fine but when two nodes gets terminated the cluster Leader election fails
and cluster is failing.
2. Log rotation and upload needs to be implemented.
