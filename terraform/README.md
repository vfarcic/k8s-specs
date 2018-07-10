Provision Kubenetes with kubeadm + Terraform + Packer
=================

## Requirements:

* AWS Cli
* Packer
* Terraform

Note: some of this requirements are covered in DevOps 2.4 Book in Appendix B

## Bake the kubernetes snapshot: 

```bash
export DIGITALOCEAN_API_TOKEN="<your_DO_token>"

cd terraform

packer build -machine-readable \
    packer-kubernetes.json \
    | tee packer-kubernetes.log
```

Create a key pair:

```bash
ssh-keygen -t rsa -P "" -f ./k8s-key
```

Create the cluster 

```bash
export TF_VAR_token=$DIGITALOCEAN_API_TOKEN

export TF_VAR_k8s_snapshot_id=$(grep \
    'artifact,0,id' \
    packer-kubernetes.log \
    | cut -d: -f2)

export TF_VAR_do_space="<your_do_space>"

export TF_VAR_space_access_key="<your_space_access_key>"

export TF_VAR_space_secret_key="<your_space_secret_key>"

terraform init

terraform plan \
    -out plan

terraform apply plan
```


Log into your new K8s cluster:

```bash
ssh -i k8s-key \
    root@$(terraform output master-ip)

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl get nodes
```

```
NAME         STATUS    ROLES     AGE       VERSION
k8s-master   Ready     master    2m        v1.9.7
k8s-node-1   Ready     <none>    1m        v1.9.7
k8s-node-2   Ready     <none>    1m        v1.9.7
```

```bash
exit

ssh -i k8s-key \
    root@$(terraform output master-ip) \
    "cat /etc/kubernetes/admin.conf" \
    | tee admin.conf

cd ../

export KUBECONFIG=terraform/admin.conf

kubectl get nodes
```

## To teardown the cluster

```bash
cd  terrraform

terraform destroy -force
```

## To modify the number of nodes

```bash
export TF_VAR_k8s_nodes=3

terraform plan \
    -out plan

terraform apply plan
```
