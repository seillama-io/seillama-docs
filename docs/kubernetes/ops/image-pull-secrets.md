# Add image pull secret on K8s

Create your authentication Secret to use from your registry authentication file (e.g. `.config/containers/auth.json` for Podman):

```sh
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
    --type=kubernetes.io/dockerconfigjson
```

Next, modify the required service account (e.g. `default`) for the namespace to use this Secret as an `imagePullSecret`.

```sh
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}], "secrets": [{"name": "regcred"}]}'
```

## Note

Above process fixes the following issue: `Too Many Requests - Server message: toomanyrequests: You have reached your pull rate limit. You may increase the limit by authenticating and upgrading: https://www.docker.com/increase-rate-limit` due to the pull rate limit when pulling image from Docker Hub with anonymous user, this limit is usually reached very quickly due to the nature of K8s pulling a lot of images from single IP.
