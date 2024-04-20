# Regularly-switch-ip

This script is used to automatically switch IP addresses in Linux systems.

## Features

- Support Debian / Ubuntu / Centos.
- The IP is persistent and will still take effect after restarting.
- Support configuring virtual interface like eth0:0
 
## Installation

To get started with these scripts, clone this repository to your local machine:

```bash
git clone https://github.com/Lucien-Yang/regularly-switch-ip.git
cd regularly-switch-ip
```

Ensure that the scripts are executable:

```bash
chmod +x switch_ip.sh
```

## Usage

### Configuring network file dir
Replace this line with the actual network configuration file directory.
```bash
CONFIG_FILE="/etc/network/interfaces.d/50-cloud-init"
```

### Configuring IP Groups
Format: IP/mask gateway iface
```bash
# Example:
# GROUP1=("192.168.1.100/24 192.168.1.1 eth0" "10.0.0.100/24 10.0.0.1 eth1")
# GROUP2=("192.168.1.101/24 192.168.1.1 eth0" "10.0.0.101/24 10.0.0.1 eth1")
```

### Configuring Cron
Add the script to crontab for periodic execution.
```bash
# Example: Executed every Tuesday at 3 a.m.
0 03 * * 2 /path/switch_ip.sh
```


## Contributing
Contributions are welcome! If you have improvements or bug fixes:

1. Fork the repository.
2. Create a new branch with a meaningful name.
3. Commit your changes.
4. Make a pull request.

## License
This project is licensed under the MIT License - see the LICENSE.md file for details.
