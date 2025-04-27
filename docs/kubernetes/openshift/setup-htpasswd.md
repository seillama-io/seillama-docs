# Configuring an `htpasswd` identity provider in OpenShift

Configure the `htpasswd` identity provider to allow users to log in to OpenShift Container Platform with credentials from an `htpasswd` file.

## Content

- [Configuring an `htpasswd` identity provider in OpenShift](#configuring-an-htpasswd-identity-provider-in-openshift)
  - [Content](#content)
  - [Creating the `htpasswd` file](#creating-the-htpasswd-file)
  - [Creating the `htpasswd` secret](#creating-the-htpasswd-secret)
  - [Adding the `htpasswd` identity provider to your cluster](#adding-the-htpasswd-identity-provider-to-your-cluster)

## Creating the `htpasswd` file

To use the `htpasswd` identity provider, you must generate a flat file that contains the user names and passwords for your cluster by using [`htpasswd`](http://httpd.apache.org/docs/2.4/programs/htpasswd.html).

**Prerequisites**

*   Have access to the `htpasswd` utility. On Red Hat Enterprise Linux this is available by installing the `httpd-tools` package.

**Procedure**

1.  Create or update your flat file with a user name and hashed password:

    ```sh
    htpasswd \-c \-B \-b </path/to/users.htpasswd\> <username\> <password\>
    ```    

2.  Continue to add or update credentials to the file:

    ```sh
    htpasswd \-B \-b </path/to/users.htpasswd\> <user\_name\> <password\>
    ```

## Creating the `htpasswd` secret

To use the `htpasswd` identity provider, you must define a secret that contains the `htpasswd` user file.

**Prerequisites**

*   Create an `htpasswd` file.

**Procedure**

*   Create a `Secret` object that contains the `htpasswd` users file:
    
    ```sh
    oc create secret generic htpass-secret --from-file\=htpasswd\=<path\_to\_users.htpasswd\> \-n openshift-config
    ```    

## Adding the `htpasswd` identity provider to your cluster

The following custom resource (CR) shows the parameters and acceptable values for an `htpasswd` identity provider.

```yaml
cat <<EOF | oc apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: htpasswd
    mappingMethod: claim 
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret 
EOF
```
