# Omni

> [!IMPORTANT]
>
> Tested on Ubuntu 24.04 Standard amd64 LXC on Proxmox 8.4.1
>
> In case you're using LXC, make sure to enable FUSE features.
> And add these lines to your container config (/etc/pve/lxc/xxx.conf):
>
> ```
> lxc.mount.entry: /dev/fuse dev/fuse none bind,create=file,optional
> lxc.mount.auto: cgroup:rw
> ```
>
> And add device passthrough to your container:
> `/dev/net/tun` for wireguard support

- [See the full documentation here](https://omni.siderolabs.com/how-to-guides/self_hosted/index)
- [SAML Authentication with Authentik guide](https://dbodky.me/blog/configuring-saml-authentication-for-omni-with-authentik/)
