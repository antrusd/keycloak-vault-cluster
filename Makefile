.PHONY: cert up unseal info stop down clean


certs/ca.crt:
	openssl req -x509 -sha256 -days 1825 -newkey rsa:4096 -nodes -subj "/C=TR/ST=Ankara/L=Ankara/O=Company/OU=IT/CN=Root CA" -keyout certs/ca.key -out certs/ca.crt
	chmod 0644 certs/ca.*

certs/wildcard-example-com.crt: certs/ca.crt
	openssl req -nodes -newkey rsa:4096 -keyout certs/wildcard-example-com.key -out certs/wildcard-example-com.csr -subj "/C=TR/ST=Ankara/L=Ankara/O=Company/OU=IT/CN=*.example.com" -addext "subjectAltName = DNS:*.example.com"
	openssl x509 -req -CA certs/ca.crt -CAkey certs/ca.key -in certs/wildcard-example-com.csr -out certs/wildcard-example-com.crt -days 365 -copy_extensions copy -CAcreateserial
	cat certs/ca.crt >> certs/wildcard-example-com.crt
	chmod 0644 certs/wildcard-example-com.*

up: certs/wildcard-example-com.crt
	docker compose up -d

vault/creds/keys:
	@docker exec -ti vault01 /vault/unseal.sh
	@echo "Please find the vault keys in vault/creds/keys"

unseal: vault/creds/keys

info: unseal
	@docker inspect --format='Keycloak URL      : https://{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' keycloak01
	@docker inspect --format='Vault URL         : https://{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}:8200' vault01
	@grep "Initial Root Token" vault/creds/keys

stop:
	docker compose stop

down: stop
	docker compose down -v

clean: down
	rm -vf vault/cert/vault-key.pem vault/cert/vault-cert.pem
	rm -vf vault/creds/keys vault/creds/status
	rm -vf keycloak/cert/keycloak-key.pem keycloak/cert/keycloak-cert.pem
	rm -vf certs/ca.*
	rm -vf certs/wildcard-example-com.*
