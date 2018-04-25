# TODO: Convert env. vars to arguments

if [[ -z "${BUCKET_NAME}" ]]; then
    echo "Creating an S3 bucket"
    export BUCKET_NAME=devops23-$(date +%s)
    # TODO: Check whether the bucket exists and create it if it doesn't
    aws s3api create-bucket --bucket $BUCKET_NAME --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
fi

export KOPS_STATE_STORE=s3://$BUCKET_NAME

# TODO: Create `alias` for Windows

kops create cluster \
  --name ${NAME:-devops23.k8s.local} \
  --master-count ${MASTER_COUNT:-3} \
  --node-count ${NODE_COUNT:-1} \
  --master-size ${MASTER_SIZE:-t2.small} \
  --node-size ${NODE_SIZE:-t2.small} \
  --zones $ZONES \
  --master-zones $ZONES \
  --ssh-public-key ${SSH_PUBLIC_KEY:-cluster/devops23.pub} \
  --networking kubenet \
  --authorization RBAC \
  --yes

# TODO: export `kubecfg` for Windows

until kops validate cluster
do
    echo "Cluster is not yet ready. Sleeping for a while..."
    sleep 30
done

kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/ingress-nginx/v1.6.0.yaml

kubectl -n kube-ingress rollout status deployment ingress-nginx

if [[ ! -z "${USE_HELM}" ]]; then
    kubectl create -f helm/tiller-rbac.yml --record --save-config
    helm init --service-account tiller
    kubectl -n kube-system rollout status deploy tiller-deploy
fi

echo ""
echo "------------------------------------------"
echo ""
echo "The cluster is ready. Please execute the commands that follow to create the environment variables."
echo ""
echo "export BUCKET_NAME=$BUCKET_NAME"
echo "export KOPS_STATE_STORE=$KOPS_STATE_STORE"