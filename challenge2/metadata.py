import boto3
import json

region = "us-east-1"
# referring ec2 as object
ec2 = boto3.client("ec2", region_name=region)
instance_full_details = ec2.describe_instances().get("Reservations")
find_item = "InstanceId"
find_item2 = "State"
output1 = []
output2 = []

for instance in instance_full_details:
    group_instances = instance["Instances"]
    for instance_id in group_instances:
        res1 = instance_id.get(find_item)
        output1.append(res1)
        res2 = instance_id.get(find_item2)
        output2.append(res2.get("Name"))

end_result = json.dumps(dict(zip(output1, output2)))
json_end_result = json.loads(end_result)
print(json_end_result)
        

