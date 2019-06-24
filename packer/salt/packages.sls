Asia/Singapore:
  timezone.system
  
fs.file-max:
  sysctl.present:
    - value: 2097152

/etc/security/limits.conf:
  file.append:
    - text:
      - "*         hard    nofile      500000"
      - "*         soft    nofile      500000"
      - "root      hard    nofile      500000"
      - "root      soft    nofile      500000"

monitor-packages:
  pkg.installed:
    - pkgs:
      - perl-Switch
      - perl-DateTime
      - perl-Sys-Syslog
      - perl-LWP-Protocol-https
      - perl-Digest-SHA
      - zip
      - unzip
      - nfs-utils
      - telnet

consul-binary:
  archive.extracted:
    - name: /usr/local/bin
    - source: https://releases.hashicorp.com/consul/1.5.1/consul_1.5.1_linux_amd64.zip
    - skip_verify: True
    - enforce_toplevel: False
    - user: root
    - group: root
    - trim_output: 20