# Virtualhost script

Script to create or delete Apache virtualhosts with corresponding public and log directories on Debian and Ubuntu.

## Installation

```bash
$ cd /usr/local/bin
$ sudo wget -O virtualhost https://raw.githubusercontent.com/NordicPinoyLab/virtualhost/master/virtualhost.sh
$ sudo chmod +x virtualhost
```

### Assumption

The website is owned by a non-root user, and user has been added to the Apache group `www-data`

```bash
$ sudo adduser ${USER} www-data
```

## Usage

Basic command line syntax:

```bash
$ sudo virtualhost [create | delete] [domain] [optional custom_dir]
```

### Examples

To create a new virtualhost:

```bash
$ sudo virtualhost create example.com
```
To create a new virtualhost with custom directory name:

```bash
$ sudo virtualhost create example.com custom_dir
```

To delete a virtualhost

```bash
$ sudo virtualhost delete example.com
```

To delete a virtual host with custom directory name:

```
$ sudo virtualhost delete example.com custom_dir
```

### Default configuration

New virtualhost:
- The virtualhost will be created at `/var/www/webapps/example.com`
- Access and log files will be at `/var/www/webapps/example.com/logs`
- Public directory is at `/var/www/webapps/example.com/web`

New virtualhost with custom directory name:
- The virtualhost will be created at `custom_dir`
- Access and log files will be at `custom_dir/logs`
- Public directory is at `custom_dir/web`
