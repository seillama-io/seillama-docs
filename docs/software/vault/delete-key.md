# Delete Hashicorp Vault key

Because this is a potentially catastrophic operation, the `deletion_allowed` attribute of a key is disabled by default and must therefore be set using the key's `/config` endpoint:

```sh
export PATH_TO_KEY=<CHANGEME> # Set vault path to your key 
cat <<EOF > payload.json
{
  "deletion_allowed": true
}
EOF
curl --header X-Vault-Token:$VAULT_TOKEN \
    --request POST \
    --data @payload.json \
    $VAULT_ADDR/v1/transit/$PATH_TO_KEY/config
vault delete $PATH_TO_KEY
rm payload.json
```
