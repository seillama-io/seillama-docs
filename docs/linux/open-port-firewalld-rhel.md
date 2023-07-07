# Open port on RHEL with firewalld

To open a port on your RHEL (Red Hat Enterprise Linux) virtual machine, you'll need to configure the firewall settings on the VM itself, not on your macOS host.

To open a port on your RHEL VM, you can follow these steps:

1. Connect to your RHEL VM: Use your preferred method to connect to your RHEL VM, such as SSH or a console.

2. Check the status of the firewall: Run the following command to check the status of the firewalld service:
   ```sh
   sudo systemctl status firewalld
   ```

3. Open the desired port: If the firewalld service is active, you can use the `firewall-cmd` command to open the port. Run the following command, replacing `<port>` with the actual port number:
   ```sh
   sudo firewall-cmd --zone=public --add-port=<port>/tcp --permanent
   ```

   This command adds a permanent rule to the public zone of the firewall, opening the specified TCP port.

4. Reload the firewall configuration: After adding the rule, you need to reload the firewall configuration for the changes to take effect. Run the following command:
   ```sh
   sudo firewall-cmd --reload
   ```

5. Verify the rule: You can use the `firewall-cmd` command with the `--list-all` option to verify that the rule was added correctly. Run the following command:
   ```sh
   sudo firewall-cmd --list-all
   ```

   This command displays a list of all the active firewall rules, including the newly added rule for the open port.

Once you've completed these steps on your RHEL VM, the specified port should be open and accessible.

Please note that these instructions assume you have administrative privileges on the RHEL VM and that you have the `firewall-cmd` command available.
