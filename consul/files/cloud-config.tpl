#cloud-config
write_files:
  - path: "/root/backup/backup.sh"
    permissions: "0744"
    owner: "root:root"
    encoding: "base64"
    content: |
      ${shellscript}