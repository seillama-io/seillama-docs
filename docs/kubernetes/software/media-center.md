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

## Optional: BitTorrent + VPN setup

### Prerequisites

- Download a wireguard configuration from your VPN provider.
- Create a `qbittorrent-config` PVC.
- Use your existing `media-pvc` PVC (or whatever one you use).

### Setup

1. Create a `qbt-wg.yaml` file with the following template updated with your wireguard configuration and ingress hostname:
2. Run `kubectl apply -f qbt-wg.yaml -n media-center`
3. Once deployed, navigate to your qbittorrent UI? go to **settings** >  **Advanced** > **Network interface:** and select the `wg0` interface.
4. You can validate that qbittorrent is using the VPN interface by using the magnet link from [whatismyip.net](https://www.whatismyip.net/tools/torrent-ip-checker/index.php) and checking the IP that's returned.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wg-conf
type: Opaque
stringData:
  wg0.conf: |
    # PLACE YOUR WIREGUARD CONFIG HERE
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: qbt-wg
spec:
  selector:
    matchLabels:
      app: qbt-wg
  template:
    metadata:
      labels:
        app: qbt-wg
    spec:
      volumes:
      - name: wg-conf
        secret:
          secretName: wg-conf
      - name: qbt-conf
        persistentVolumeClaim:
          claimName: qbittorrent-config
      - name: media
        persistentVolumeClaim:
          claimName: media-pvc
      containers:
      - name: wireguard
        image: lscr.io/linuxserver/wireguard:latest
        env:
        - name: TZ
          value: Europe/Paris
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "128Mi"
            cpu: "200m"
        volumeMounts:
        - name: wg-conf
          mountPath: /config/wg_confs
        ports:
        - containerPort: 51820
          name: main
          protocol: UDP
        securityContext:
          privileged: true
          capabilities:
            add:
            - NET_ADMIN
      - name: qbittorrent
        image: lscr.io/linuxserver/qbittorrent:latest
        env:
        - name: TZ
          value: Europe/Paris
        - name: WEBUI_PORT
          value: "8080"
        - name: TORRENTING_PORT
          value: "6881"
        resources:
          limits:
            memory: "1Gi"
            cpu: "1"
          requests:
            memory: "128Mi"
            cpu: "200m"
        volumeMounts:
        - name: qbt-conf
          mountPath: /config
        - name: media
          mountPath: /media
        ports:
        - containerPort: 8080
          name: main
          protocol: TCP
        - containerPort: 6881
          name: torrent
          protocol: TCP
        - containerPort: 6881
          name: torrentudp
          protocol: UDP
---
apiVersion: v1
kind: Service
metadata:
  name: qbt-wg-web
spec:
  selector:
    app: qbt-wg
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: qbt-wg-web
  labels:
    name: qbt-wg-web
spec:
  rules:
  - host: qbt.example.com
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: qbt-wg-web
            port: 
              number: 8080
```
