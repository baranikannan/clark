import boto3, json, re
 
client = boto3.client('route53', aws_access_key_id="", aws_secret_access_key="")
hostedZoneId = "Z03176201EOGIVF2UQ1DV"
 
instance_id = "i-02c0ebaf7306fdecd"
ec2 = boto3.resource('ec2')
route53 = boto3.client('route53')

#instance_id = event['detail']['instance-id']
instance = ec2.Instance(instance_id)
instance_ip = instance.private_ip_address
instance_name = search(instance.tags, 'Name')
 
print("InstanceID -", instance)
print("Instance IP -", instance_ip)
print("Instance Name -", instance_name)
 
 
#print("DNS record status %s "  % response['ChangeInfo']['Status'])
#print("DNS record response code %s " % response['ResponseMetadata']['HTTPStatusCode'])
