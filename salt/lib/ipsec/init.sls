ipsec_package:
  pkg.installed:
    - pkgs:
      - strongswan
      - libstrongswan-standard-plugins
      - mgit-check-mk-ipsec-agent
    - install_recommends: False

ipsec_override_service:
  file.managed:
    - name: /etc/systemd/system/strongswan.service.d/override.conf
    - source: salt://lib/ipsec/strongswan.override.conf
    - makedirs: True
    - require:
      - pkg: ipsec_package

ipsec_config:
  file.managed:
    - name: /etc/ipsec.conf
    - source: salt://lib/ipsec/ipsec.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ipsec_package

ipsec_secrets:
  file.managed:
    - name: /etc/ipsec.secrets
    - source: salt://lib/ipsec/ipsec.secrets
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: ipsec_package

ipsec_conn_dir:
  file.directory:
    - name: /etc/ipsec.d/conn/
    - user: root
    - group: root
    - mode: 700
    - makedirs: True
    - require:
      - pkg: ipsec_package

ipsec_conn_dir_clean:
  file.directory:
    - name: /etc/ipsec.d/conn/
    - clean: True
    - require:
      - file: ipsec_conn_dir

ipsec_secrets_dir:
  file.directory:
    - name: /etc/ipsec.d/secrets/
    - user: root
    - group: root
    - mode: 700
    - makedirs: True
    - require:
      - pkg: ipsec_package

ipsec_secrets_dir_clean:
  file.directory:
    - name: /etc/ipsec.d/secrets/
    - clean: True
    - require:
      - file: ipsec_secrets_dir

ipsec_service:
  service.running:
    - name: strongswan
    - enable: True
    - reload: True
    - watch:
      - file: ipsec_config
      - file: ipsec_secrets
      - file: ipsec_override_service
      - file: ipsec_conn_dir_clean
      - file: ipsec_secrets_dir_clean
