import boto3

def check_public_access(bucket_name):
    s3 = boto3.client('s3')
    
    response = s3.get_bucket_acl(Bucket=bucket_name)
    for grant in response['Grants']:
        if 'URI' in grant.get('Grantee', {}):
            uri = grant['Grantee']['URI']
            if uri.endswith('AllUsers') or uri.endswith('AuthenticatedUsers'):
                return True
    
    return False

def list_public_buckets():
    s3 = boto3.client('s3')
    
    response = s3.list_buckets()
    
    public_buckets = []
    
    for bucket in response['Buckets']:
        bucket_name = bucket['Name']
        
        if check_public_access(bucket_name):
            public_buckets.append(bucket_name)
    
    return public_buckets

if __name__ == "__main__":
    public_buckets = list_public_buckets()
    
    if not public_buckets:
        print("No public buckets found.")
    else:
        print("Public buckets:")
        for bucket in public_buckets:
            print(bucket)