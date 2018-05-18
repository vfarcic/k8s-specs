aws iam remove-user-from-group \
  --user-name kops \
  --group-name kops

aws iam delete-access-key --user-name kops --access-key-id $(cat creds/kops-creds | jq -r '.AccessKey.AccessKeyId')

aws iam delete-user \
  --user-name kops

aws iam detach-group-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess \
  --group-name kops

aws iam detach-group-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
  --group-name kops

aws iam detach-group-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess \
  --group-name kops

aws iam detach-group-policy \
  --policy-arn arn:aws:iam::aws:policy/IAMFullAccess \
  --group-name kops

aws iam delete-group \
  --group-name kops
