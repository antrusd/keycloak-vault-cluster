listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/vault/cert/wildcard-example-com.crt"
  tls_key_file  = "/vault/cert/wildcard-example-com.key"
}

storage "consul" {
  address = "consul01:8500"
  path    = "vault/"
}

ui = true
disable_mlock = "true"
api_addr = "http://127.0.0.1:8200"
log_level = "Debug"
