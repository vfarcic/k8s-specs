# Kubernetes AWS

## First Run / Setup 

Install AWS CLI tool and kops

See AWS docs for install AWS CLI, and use homebrew for kops

```
brew install kops
```

Get root or admin access keys

Save keys to `./creds/root-creds` in following format - .gitignore creds or add as meta project so keys are not checked in with this project!

```
{
    "AccessKey": {
        "AccessKeyId": "...",
        "SecretAccessKey": "...",
    }
}

```

To set our context to the root user, run

```
source root.env
```

Then, run the setup with

```
sh ./setup.sh
```

This will generate some new IAM roles, and create a user kops. It will also
prompt the user for their organizations name and generate a new bucket id.
Org and bucket id are then written to kops.env.

Next, Switch to the user `kops`

```
source kops.env
```

Then run :

```bash
sh cluster-setup.sh
```

## Delete

To delete your cluster:

```
sh delete-kops.sh
```

To delete kops AWS resources:

```
sh delete-aws.sh
```