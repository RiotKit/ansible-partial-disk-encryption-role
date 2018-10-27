Secure Storage
==============

Encrypts the data with a TrueCrypt AES 256 hidden volume, and exposes a HTTP endpoint for having a possibility
to enter the passphrase when the server will go down.

Protect your server against hosting providers. Even if they would mount your storage it will be encrypted.
Its much more difficult to get into your data when its encrypted, but REMEMBER, it's not impossible!

```bash
ansible-galaxy install blackandred.server_secure_storage
```

Mounting and unmounting from shell
----------------------------------

To mount/unmount a volume from shell there are prepared easy to use scripts.

```bash
# please replace "storage" with the name you placed in "enc_mount_name" variable (see configuration reference)

# mounting
/usr/local/bin/tcmount-storage.sh 'your-secret-here'

# unmounting
/usr/local/bin/tcunmount-storage.sh
```

Mounting by a HTTP call
-----------------------

You can mount the storage using an HTTP call, so also you can easily automate the process using some healthchecks.

```bash
curl -v http://your-host:8015/deploy/volume_mount?enc_token=YOUR-PASSWORD-THERE&token=YOUR-DEPLOYER-TOKEN-HERE
```

Legend:
- enc_token: Its a volume password or secret password (depends on which volume you want to mount)
- token: Thin-Deployer token, configurable in `deployer_token` (see: configuration reference)

Notes:
- IT IS HIGHLY RECOMMENDED TO HIDE DEPLOYER SERVICE BEHIND A SSL GATEWAY

Configuration reference
-----------------------

```yamlex
    roles:
      - role: blackandred.server_secure_storage
        tags: decrypt
        vars:
            enc_file: /.do-not-delete                  # path, where all of the data will be stored
            enc_file_size: 10000M                      # examples: 256M, 20G, 500G
            enc_mount_name: storage                    # mount name, should be a-z, lower case, without special letters
            enc_file_filesystem: ext4                  # any filesystem supported by mkfs (and supported by the operating system)
            enc_filesystem_create_if_not_exists: true

            # passwords, change them, NOTE: You can keep them secure in an Ansible Vault
            # by default the hidden volume is mounted during deployment time
            # but normally you can choose over the HTTP endpoint or via SHELL which volume you want to mount
            # by choosing one of defined passwords just
            enc_passphrase: "test123"
            enc_hidden_volume_passphrase: "hidden123"
            enc_hidden_volume_size: "9950M"

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

Hooks PRE/POST
--------------

Before encryption (detaching the volume) you can execute your code to eg. shutdown services,
and after decryption you can bring them up back.

Example:

```yamlex
    hook_pre_mount: ""

    hook_post_mount: >
      set -x;

      mkdir -p /mnt/storage/project /mnt/storage/docker /project /var/lib/docker;
      mount -o bind /mnt/storage/project /project || exit 1;
      mount -o bind /mnt/storage/docker /var/lib/docker || exit 1;
      mount --bind /var/lib/docker/plugins /var/lib/docker/plugins || true;
      mount --make-private /var/lib/docker/plugins || true;

      if [[ -f /etc/systemd/system/project.service ]]; then
          sudo systemctl restart docker;
          sleep 5;
          sudo systemctl restart project;
      fi;

    hook_pre_unmount: >
      if [[ -f /etc/systemd/system/project.service ]]; then
          sudo systemctl disable docker;
          sudo systemctl disable project;

          sudo systemctl stop project;
          sudo systemctl stop docker;
      fi;

      umount /var/lib/docker/plugins || true;
      umount /project || true;
      umount /var/lib/docker || true;

    hook_post_unmount: ""
```
