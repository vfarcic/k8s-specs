mkdir -p creds

aws iam create-group \
  --group-name kops

aws iam attach-group-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess \
  --group-name kops

aws iam attach-group-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
  --group-name kops

aws iam attach-group-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess \
  --group-name kops

aws iam attach-group-policy \
  --policy-arn arn:aws:iam::aws:policy/IAMFullAccess \
  --group-name kops

aws iam create-user \
  --user-name kops

aws iam add-user-to-group \
  --user-name kops \
  --group-name kops

aws iam create-access-key \
  --user-name kops >creds/kops-creds

BUCKET_ID=$(date +%s)
echo $BUCKET_ID
sed -i .bak 's/MY_BUCKET_ID/'$BUCKET_ID'/' ./kops.env

echo "Enter your organization's name (lowercase): "
read -r org

sed -i .bak 's/MY_ORG_NAME/'$org'/' ./kops.env

aws ec2 create-key-pair \
  --key-name kops \
  | jq -r '.KeyMaterial' \
  >creds/kops.pem

chmod 400 creds/kops.pem

ssh-keygen -y -f creds/kops.pem \
  >creds/kops.pub
