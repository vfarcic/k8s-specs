```bash
packer build \
    -machine-readable \
    workstation.json \
    | tee workstation.log
```