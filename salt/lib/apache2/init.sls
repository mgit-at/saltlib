apache2_package:
  pkg.installed:
    - pkgs:
      - apache2
    - install_recommends: False

apache2_service:
  service.running:
    - name: apache2
    - enable: True
    - reload: True
    - require:
      - pkg: apache2_package

apache2_security_conf_absent:
  file.absent:
    - name: /etc/apache2/conf-enabled/security.conf
    - require:
      - pkg: apache2_package
    - watch_in:
      - service: apache2_service

apache2_custom_security_conf:
  file.managed:
    - name: /etc/apache2/conf-available/custom_security.conf
    - source: salt://lib/apache2/custom_security.conf
    - require:
      - pkg: apache2_package
    - watch_in:
      service: apache2_service

apache2_custom_security_conf_enable:
  file.symlink:
    - name: /etc/apache2/conf-enabled/custom_security.conf
    - target: ../conf-available/custom_security.conf
    - require:
      - file: apache2_custom_security_conf
    - watch_in:
      - service: apache2_service
