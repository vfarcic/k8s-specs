Provision Kubenetes with kubeadm + Terraform + Packer
=================

## Requirements:

* AWS Cli
* Packer
* Terraform

Note: some of this requirements are covered in DevOps 2.4 Book in Appendix B

## Bake the kubernetes AMI: 

```bash
packer build packer-kubernetes.json
```

Create a key pair:

```bash
aws ec2 create-key-pair --key-name k8s-key | jq -r '.KeyMaterial' > k8s-key.pem
```

Create the master node:

```bash
terraform init
terraform plan -target="aws_instance.kube-master" \
    -target="aws_eip_association.eip_assoc" \
    -var k8s_key_name="k8s-key" \
    -out=plan

terraform apply plan
```

Once the master node is up and runnig. You can Provision and Join the two nodes to the cluster:

```bash
ssh-keyscan $(terraform output master-ip) >> ~/.ssh/known_hosts

export TF_VAR_k8s_join_command=$(ssh -i k8s-key.pem ubuntu@$(terraform output master-ip) "sudo kubeadm token create --print-join-command")

terraform plan -out plan
terraform apply plan
```

Log into your new K8s cluster:

```bash
ssh -i k8s-key.pem ubuntu@$(terraform output master-ip)
kubectl get nodes
ubuntu@ip-172-31-87-132:~$ kubectl get nodes
NAME               STATUS     ROLES     AGE       VERSION
ip-172-31-87-132   NotReady   master    6m        v1.9.7
ip-172-31-88-36    NotReady   <none>    1m        v1.9.7
ip-172-31-92-94    NotReady   <none>    1m        v1.9.7
```

## To teardown the cluster
```bash
terraform destroy --force
```

