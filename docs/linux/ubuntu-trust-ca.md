# Ubuntu: trust a new Certificate Authority

Assuming a PEM-formatted root CA certificate is in `local-ca.crt`, follow the steps below to install it.

**Note**: It is important to have the `.crt` extension on the file, otherwise it will not be processed.


```sh
sudo apt-get install -y ca-certificates
sudo cp local-ca.crt /usr/local/share/ca-certificates
sudo update-ca-certificates
```

After this point you can use Ubuntu’s tools like `curl`, `wget` or `docker login` to connect to local sites.

Source: [https://ubuntu.com/server/docs/security-trust-store](https://ubuntu.com/server/docs/security-trust-store)
