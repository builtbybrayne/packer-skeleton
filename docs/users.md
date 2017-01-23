# Users

## Default User

All VMs have a standard user with sudo privileges.

### Private Key

[/keys/id_rsa](/keys/id_rsa)

Run:

```
$ ssh -i /path/to/id_rsa <USER>@<VM_IP|VM_HOSTNAME>
```

### Password

SSH password-based login is not allowed. But you will need the password for other functionality. 

## Environment-Specific Users

Each environment has it's own bootstrap user, which we leave on the system. They all have ssh access disabled. 


### Vagrant

User: `vagrant` 
Password: `vagrant`


### Standard Ubuntu install (e.g. AWS)

User: `ubuntu`
Password: `<empty>`

