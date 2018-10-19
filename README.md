Secure Storage
==============

Encrypts the data with a TrueCrypt AES 256 hidden volume, and exposes a HTTP endpoint for having a possibility
to enter the passphrase when the server will go down.

```bash
ansible-galaxy install blackandred.server_secure_storage
```

Configuration reference
-----------------------

```yamlex
enc_file: /.do-not-delete                  # path, where all of the data will be stored
enc_file_size: 400M                        # examples: 256M, 20G, 500G
enc_mount_name: storage                    # mount name, should be a-z, lower case, without special letters
enc_file_filesystem: ext4                  # any filesystem supported by mkfs (and supported by the operating system)
enc_filesystem_create_if_not_exists: true

# passwords, change them
enc_passphrase: "test123"
enc_hidden_volume_passphrase: "hidden123"
enc_hidden_volume_size: "390M"

# tcplay settings
hashing_algorithm: whirlpool
encryption_algorithm: AES-256-XTS

# Mounting webhook
# ================
#  Allows to expose a HTTP endpoint, so you could
#  invoke that endpoint to put the passphrase to mount the volume
#  eg. after server crash. So the password will not be stored on the server
#  and how you will secure it is your concern.
#
deployer_token: ""                   # set a token to enable
slack_or_mattermost_webhook_url: ""  # put a slack/mattermost webhook URL to enable notifications
systemd_service_name: "volume-deployer"
deployer_listen: "0.0.0.0"
deployer_listen_port: "8015"
```
