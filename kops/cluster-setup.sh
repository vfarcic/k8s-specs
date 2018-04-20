aws ec2 create-key-pair \
  --key-name kops \
  | jq -r '.KeyMaterial' \
  >creds/kops.pem

chmod 400 creds/kops.pem

ssh-keygen -y -f creds/kops.pem \
  >creds/kops.pub

aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --create-bucket-configuration \
  LocationConstraint=$AWS_DEFAULT_REGION

kops create cluster \
  --name $NAME \
  --master-count 3 \
  --node-count 1 \
  --node-size t2.small \
  --master-size t2.small \
  --zones $ZONES \
  --master-zones $ZONES \
  --ssh-public-key creds/kops.pub \
  --networking kubenet \
  --kubernetes-version v1.8.7 \
  --authorization RBAC \
  --yes