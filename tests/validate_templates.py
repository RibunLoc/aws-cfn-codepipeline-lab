# source: validate_template.py
import boto3
import yaml
import sys
from yaml.constructor import ConstructorError

# Kết nối AWS CloudFormation
cf_client = boto3.client('cloudformation')

# Custom YAML loader để hiểu !Ref, !Sub,...
class CloudFormationLoader(yaml.SafeLoader):
    pass

def ref_constructor(loader, node):
    return {"Ref": loader.construct_scalar(node)}

def sub_constructor(loader, node):
    return {"Fn::Sub": loader.construct_scalar(node)}

def getatt_constructor(loader, node):
    return {"Fn::GetAtt": loader.construct_scalar(node)}

# Đăng ký các tag CloudFormation cần dùng
CloudFormationLoader.add_constructor("!Ref", ref_constructor)
CloudFormationLoader.add_constructor("!Sub", sub_constructor)
CloudFormationLoader.add_constructor("!GetAtt", getatt_constructor)

def validate_template(file_path):
    try:
        with open(file_path, 'r') as file:
            template_body = file.read()

        # Gọi AWS để validate template
        response = cf_client.validate_template(TemplateBody=template_body)

        print(f"\n[✔️] Template '{file_path}' passed syntax validation.")
        print("\nTemplate Parameters:")
        for param in response.get('Parameters', []):
            default = param.get('DefaultValue', 'No default')
            print(f"  - {param['ParameterKey']} (Default: {default})")

        # Load YAML bằng CloudFormation-aware loader
        return yaml.load(template_body, Loader=CloudFormationLoader)

    except Exception as e:
        print(f"\n[❌] Template '{file_path}' failed validation:")
        print(str(e))
        sys.exit(1)

def check_resource_links(template):
    resources = template.get('Resources', {})
    if not resources:
        print("\n[❌] No resources found in template.")
        sys.exit(1)

    print("\n🔗 Checking resource links:")
    for name, resource in resources.items():
        res_type = resource.get('Type', 'Unknown')
        props = resource.get('Properties', {})
        if 'VpcId' in props:
            print(f"  - Resource '{name}' ({res_type}) linked to VPC: {props['VpcId']}")
        if 'SubnetId' in props:
            print(f"  - Resource '{name}' ({res_type}) linked to Subnet: {props['SubnetId']}")
        if 'RouteTableId' in props:
            print(f"  - Resource '{name}' ({res_type}) linked to Route Table: {props['RouteTableId']}")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python validate_template.py <path_to_template.yaml>")
        sys.exit(1)

    template_file = sys.argv[1]
    template = validate_template(template_file)
    check_resource_links(template)
