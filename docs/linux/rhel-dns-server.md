# Update DNS server configuration on RHEL

## Add DNS A Records

To update the DNS server configuration on RHEL (Red Hat Enterprise Linux) and add new A records, you can follow these general steps:

1. Log in to your RHEL server with administrative privileges (such as the root user or a user with sudo access).
2. Determine which DNS server software you are using. RHEL typically uses BIND (Berkeley Internet Name Domain) as the default DNS server. However, there are alternative DNS server options like dnsmasq or PowerDNS. The specific steps may vary slightly depending on the DNS server software you have installed.
3. Locate the configuration file for your DNS server. For BIND, the configuration file is typically located at `/etc/named.conf`. For dnsmasq, it is `/etc/dnsmasq.conf`.
4. Open the configuration file using a text editor. For example, you can use the `vi` editor by running the following command:
    ```sh
    sudo vi /etc/named.conf
    ```
5. Within the configuration file, find the zone section that corresponds to the domain for which you want to add A records. The zone section typically begins with a line similar to:
    ```
    zone "example.com" IN {
    ```
6. Inside the zone section, locate the resource or record directive. This directive is used to define A records. It might look like this:
    ```
    example.com.      IN    A    192.168.1.100
    ```
7. Add a new line for each A record you want to add. The format is typically:
    ```
    hostname      IN    A    IP_address
    ```
    Replace `hostname` with the desired host or subdomain name and `IP_address` with the corresponding IP address.
8. Save the changes and exit the text editor.
9. Restart the DNS server to apply the new configuration. The command to restart the DNS server will depend on the software you are using. For BIND, you can use the following command:
    ```sh
    sudo systemctl restart named
    ```
    If you are using dnsmasq, the command would be:
    ```sh
    sudo systemctl restart dnsmasq
    ```
10. Verify that the A records have been added successfully by using a DNS lookup tool like `nslookup` or `dig`. For example, you can run:
    ```sh
    nslookup hostname.example.com
    ```
    Replace hostname.example.com with the specific hostname or subdomain you added.

That's it! You have now updated the DNS server configuration on RHEL to add new A records. Remember to adjust the steps if you are using a different DNS server software.

## Create new DNS zone

If you want to create a brand new zone in your /etc/named.conf file on RHEL, follow these steps:

1. Open the /etc/named.conf file using a text editor with administrative privileges. For example:
    ```sh
    sudo vi /etc/named.conf
    ```
2. Inside the file, locate the `options` section. This section contains global configuration options for the BIND DNS server.
3. Within the `options` section, add a new zone definition by using the following syntax:
    ```
    zone "example.com" {
        type master;
        file "/var/named/example.com.zone";
    };
    ```
    Replace `example.com` with the name of your desired domain or subdomain. Modify the `file` directive to specify the path and filename where you want to store the zone file. In this example, the zone file will be stored at `/var/named/example.com.zone`.
4. Save the changes and exit the text editor.
5. Create the zone file at the specified location (`/var/named/example.com.zone` in the example above). The zone file contains the DNS records for the zone you created. You can use a text editor to create and edit the zone file. Here's an example of a basic zone file for reference:
    ```
    $TTL 86400
    @       IN      SOA     ns1.example.com. admin.example.com. (
                            2023060101      ; Serial number
                            3600            ; Refresh
                            1800            ; Retry
                            604800          ; Expire
                            86400           ; Minimum TTL
                            )
    @       IN      NS      ns1.example.com.
    @       IN      NS      ns2.example.com.
    ns1     IN      A       192.168.1.10
    ns2     IN      A       192.168.1.11
    ```
    Modify the records according to your specific requirements, including the SOA (Start of Authority) record, NS (Name Server) records, and A (Address) records.
6. Save the zone file.
7. Restart the BIND DNS server to apply the changes:
    ```sh
    sudo systemctl restart named
    ```
8. Verify that the new zone is functioning correctly by performing DNS lookups or using DNS testing tools.

That's it! You have now created a new zone in your `/etc/named.conf` file on RHEL and defined the corresponding zone file.
