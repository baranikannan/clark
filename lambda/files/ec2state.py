import boto3
import hashlib
import json

hostedZoneId = "Z011184524Q3T52VVN9I8"
Domain_Name = "clark.test"
client = boto3.client('route53')
ec2 = boto3.resource('ec2')

def search(dicts, search_for):
    for item in dicts:
        if search_for == item['Key']:
            return item['Value']
    return None

def lambda_handler(event, context):
    instance_id = event['detail']['instance-id']
    instance_state = event['detail']['state']
    instance = ec2.Instance(instance_id)
    instance_tags = instance.tags
    if instance_state == "running":
        instance_ip = instance.private_ip_address
        int_dns_name = instance.private_dns_name
        data = int_dns_name.split(".",1)
        domain_name = data[0]
        FullDNS_Name=(domain_name+"."+Domain_Name)
        print(FullDNS_Name)
        print(instance_ip)
        ec2.create_tags(Resources=[instance_id], Tags=[{'Key':'IntDNSname', 'Value':FullDNS_Name}, {'Key':'IntIP', 'Value':instance_ip}])
        response = client.change_resource_record_sets(
            HostedZoneId=hostedZoneId,
            ChangeBatch={
                "Comment": "Automatic DNS update",
                "Changes": [
                    {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": FullDNS_Name,
                            "Type": "A",
                            "TTL": 180,
                            "ResourceRecords": [
                                {
                                    "Value": instance_ip
                                },
                            ],
                        }
                    },
                ]
            }
        )
    elif instance_state == "terminated":
        IntDNSname = search(instance.tags, 'IntDNSname')
        instance_IP = search(instance.tags, 'IntIP')
        print(IntDNSname, " Got terminatedwhich had IP ", instance_IP)
        response = client.change_resource_record_sets(
                    HostedZoneId=hostedZoneId,
                    ChangeBatch={
                        "Comment": "Updated by Lambda DDNS",
                        "Changes": [
                            {
                                "Action": "DELETE",
                                "ResourceRecordSet": {
                                    "Name": IntDNSname,
                                    "Type": "A",
                                    "TTL": 180,
                                    "ResourceRecords": [
                                        {
                                            "Value": instance_IP
                                        },
                                    ]
                                }
                            },
                        ]
                    }
                )
    else:
        print("Function failed, Alert should be triggered")