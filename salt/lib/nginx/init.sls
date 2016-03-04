nginx_package:
  pkg.installed:
    - pkgs: {{ pillar.get('lib_nginx_pkgs', ['nginx'])|yaml }}
    - install_recommends: False

nginx_confd_logstash:
  file.managed:
    - name: /etc/nginx/conf.d/logstash.conf
    - source: salt://lib/nginx/logstash.conf
    - require:
      - pkg: nginx_package
    - watch_in:
      - service: nginx_service

nginx_confd_server_tokens:
  file.managed:
    - name: /etc/nginx/conf.d/server_tokens.conf
    - source: salt://lib/nginx/server_tokens.conf
    - require:
      - pkg: nginx_package
    - watch_in:
      - service: nginx_service

nginx_snippets_security_params:
  file.managed:
    - name: /etc/nginx/snippets/security_params.conf
    - source: salt://lib/nginx/security_params.conf
    - require:
      - pkg: nginx_package
    - watch_in:
      - service: nginx_service

nginx_snippets_ssl_params:
  file.managed:
    - name: /etc/nginx/snippets/ssl_params.conf
    - source: salt://lib/nginx/ssl_params.conf
    - require:
      - pkg: nginx_package
    - watch_in:
      - service: nginx_service

nginx_empty_directory:
  file.directory:
    - name: /var/www/nginx-empty
    - user: root
    - group: root
    - clean: True

nginx_nodefault:
  file.absent:
    - name: /etc/nginx/sites-enabled/default
    - watch:
      - pkg: nginx_package

nginx_override_service:
  file.managed:
    - name: /etc/systemd/system/nginx.service.d/service.conf
    - makedirs: True
    - contents: "[Service]\nCPUAccounting=true\nSlice=service.slice\n"
    - require:
      - pkg: nginx_package
    - watch_in:
      - service: nginx_service

nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - pkg: nginx_package
      - file: nginx_empty_directory
      - file: nginx_nodefault
    - watch:
      - file: nginx_override_service

nginx_apache2utils_package:
  pkg.installed:
    - pkgs:
      - apache2-utils
    - install_recommends: False
