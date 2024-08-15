.PHONY: certs up unseal info stop down clean


certs/ca.crt:
	openssl req -x509 -sha256 -days 1825 -newkey rsa:4096 -nodes -subj "/C=TR/ST=Ankara/L=Ankara/O=Company/OU=IT/CN=Root CA" -keyout certs/ca.key -out certs/ca.crt

certs/wildcard-example-com.crt: certs/ca.crt
	openssl req -nodes -newkey rsa:4096 -keyout certs/wildcard-example-com.key -out certs/wildcard-example-com.csr -subj "/C=TR/ST=Ankara/L=Ankara/O=Company/OU=IT/CN=*.example.com" -addext "subjectAltName = DNS:*.example.com"
	openssl x509 -req -CA certs/ca.crt -CAkey certs/ca.key -in certs/wildcard-example-com.csr -out certs/wildcard-example-com.crt -days 365 -copy_extensions copy -CAcreateserial

certs: certs/ca.crt certs/wildcard-example-com.crt
	cat certs/ca.crt certs/wildcard-example-com.crt certs/wildcard-example-com.key > certs/wildcard-example-com.pem
	chmod 0644 certs/wildcard-example-com.*

up: certs
	docker compose up -d

unseal:
	@docker exec -ti vault01 /vault/unseal.sh
	@docker exec -ti vault02 /vault/unseal.sh

info:
	@echo                    'Keycloak URL      : https://keycloak.example.com'
	@docker inspect --format='Keycloak IP       : {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' keycloak
	@echo                    '==='
	@echo                    'Vault Cluster URL : https://vault.example.com:8200'
	@docker inspect --format='Vault Cluster IP  : {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' haproxy
	@docker inspect --format='Vault 01 IP       : {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vault01
	@docker inspect --format='Vault 02 IP       : {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vault02
	@echo                    '==='
	@echo                    '/etc/hosts        :'
	@echo                    ''
	@docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} keycloak.example.com' keycloak
	@docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} vault.example.com' haproxy
	@echo                    ''
	@echo                    '==='
	@grep                    'Initial Root Token:' vault/creds/vault.keys

stop:
	docker compose stop

down: stop
	docker compose down -v
	rm -vf vault/creds/vault.keys

clean: down
	rm -vf certs/ca.*
	rm -vf certs/wildcard-example-com.*
