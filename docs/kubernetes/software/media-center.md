# Self-hosted media center on K8s

## Overview

- **FlareSolverr**: proxy server to bypass Cloudflare protection.
- **qflood**: qBittorrent client with Flood UI.
- **FlareSolverr**: Indexer manager/proxy built on the popular arr net base stack to integrate with your various PVR apps.
- **Prowlarr** Indexer manager/proxy built on the popular arr net base stack to integrate with your various PVR apps.
- **Sonarr**: tv series collection manager for Usenet and BitTorrent users.
- **Radarr**: movie collection manager for Usenet and BitTorrent users.
- **Jellyfin**: Free Software Media System that puts you in control of managing and streaming your media.
- **Jellyseerr**: fork of Overseerr with support for Jellyfin and Emby. It can be used to manage requests for your media library.
- **Jellystat**: A free and open source Statistics App for Jellyfin.

## Prerequisites 

- Kubernetes cluster running on `amd64` (because of TrueCharts dependency) accessible with `kubectl` CLI
  - **Note**: Tested on K3s cluster with default `traefik` ONI.
- Install [Helm](https://helm.sh/docs/intro/install/)

## Helm repo

Get the [TrueCharts](https://truecharts.org/) Helm repository:

```sh
helm repo add truecharts https://charts.truecharts.org
helm repo update truecharts
```

## Setup environment variables

```sh
export MEDIA_NAMESPACE="media-center"
export STORAGE_CLASS="nfs-hdd" # changeme
export MEDIA_VOLUME_SIZE="4Ti" # changeme
export LB_IP="192.168.1.81" # changeme
```

## Create base resources

Create namespace:

```sh
kubectl create ns ${MEDIA_NAMESPACE}
```

Create PVC:

```sh
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-pvc
  namespace: ${MEDIA_NAMESPACE}
spec:
  storageClassName: ${STORAGE_CLASS}
  resources:
    requests:
      storage: ${MEDIA_VOLUME_SIZE}
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
EOF
```

## BitTorrent client

Install the chart:

```sh
cat <<EOF > qflood.values.yaml
ingress:
  main:
    enabled: true
    hosts:
    - host: qflood.${LB_IP}.nip.io
      paths:
      - path: /
    integrations:
      traefik:
        enabled: false
operator:
  verify:
    enabled: false
persistence:
  media:
    enabled: true
    existingClaim: media-pvc
    mountPath: "/media"
EOF
helm install qflood truecharts/qflood --values qflood.values.yaml --namespace ${MEDIA_NAMESPACE}
```

After install you should be able to reach your Flood UI on your local network at `qflood.${LB_IP}.nip.io`.

## Flaresolverr

Install the chart:

```sh
helm install flaresolverr truecharts/flaresolverr
```

## Prowlarr

Install the chart:

```sh
cat <<EOF > prowlarr.values.yaml
ingress:
  main:
    enabled: true
    hosts:
    - host: prowlarr.${LB_IP}.nip.io
      paths:
      - path: /
    integrations:
      traefik:
        enabled: false
operator:
  verify:
    enabled: false
EOF
helm install prowlarr truecharts/prowlarr --values prowlarr.values.yaml --namespace ${MEDIA_NAMESPACE}
```

After install you should be able to reach your Prowlarr instance on your local network at `prowlarr.${LB_IP}.nip.io`.

## Sonarr

Install the chart:

```sh
cat <<EOF > sonarr.values.yaml
ingress:
  main:
    enabled: true
    hosts:
    - host: sonarr.${LB_IP}.nip.io
      paths:
      - path: /
    integrations:
      traefik:
        enabled: false
operator:
  verify:
    enabled: false
persistence:
  media:
    enabled: true
    existingClaim: media-pvc
    mountPath: "/media"
EOF
helm install sonarr truecharts/sonarr --values sonarr.values.yaml --namespace ${MEDIA_NAMESPACE}
```

After install you should be able to reach your Sonarr instance on your local network at `sonarr.${LB_IP}.nip.io`.

## Radarr

Install the chart:

```sh
cat <<EOF > radarr.values.yaml
ingress:
  main:
    enabled: true
    hosts:
    - host: radarr.${LB_IP}.nip.io
      paths:
      - path: /
    integrations:
      traefik:
        enabled: false
operator:
  verify:
    enabled: false
persistence:
  media:
    enabled: true
    existingClaim: media-pvc
    mountPath: "/media"
EOF
helm install radarr truecharts/radarr --values radarr.values.yaml --namespace ${MEDIA_NAMESPACE}
```

After install you should be able to reach your Radarr instance on your local network at `radarr.${LB_IP}.nip.io`.

You can now configure Radarr:
- In Prowlarr UI, 

## Jellyfin

Install the chart:

```sh
cat <<EOF > jf.values.yaml
ingress:
  main:
    enabled: true
    hosts:
    - host: jf.${LB_IP}.nip.io
      paths:
      - path: /
    integrations:
      traefik:
        enabled: false
operator:
  verify:
    enabled: false
persistence:
  media:
    enabled: true
    existingClaim: media-pvc
    mountPath: "/media"
EOF
helm install jellyfin truecharts/jellyfin --values jf.values.yaml --namespace ${MEDIA_NAMESPACE}
```

After install you should be able to reach your Jellyfin instance on your local network at `jf.${LB_IP}.nip.io`.

## Jellyseerr

Install the chart:

```sh
cat <<EOF > jellyseerr.values.yaml
ingress:
  main:
    enabled: true
    hosts:
    - host: jellyseerr.${LB_IP}.nip.io
      paths:
      - path: /
    integrations:
      traefik:
        enabled: false
operator:
  verify:
    enabled: false
EOF
helm install jellyseerr truecharts/jellyseerr --values jellyseerr.values.yaml --namespace ${MEDIA_NAMESPACE}
```

After install you should be able to reach your Jellyseerr instance on your local network at `jellyseerr.${LB_IP}.nip.io`.

Configure Jellyseerr:
- Open UI at `jellyseerr.${LB_IP}.nip.io`.
- Connect using your Jellyfin server and account.
- Setup connection to Radarr and Sonarr.

## Jellystat

Install the chart:

```sh
cat <<EOF > jellystat.values.yaml
ingress:
  main:
    enabled: true
    hosts:
    - host: jellystat.${LB_IP}.nip.io
      paths:
      - path: /
    integrations:
      traefik:
        enabled: false
operator:
  verify:
    enabled: false
EOF
helm install jellystat truecharts/jellystat --values jellystat.values.yaml --namespace ${MEDIA_NAMESPACE}
```

After install you should be able to reach your Jellystat instance on your local network at `jellystat.${LB_IP}.nip.io`.
