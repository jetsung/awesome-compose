import Config

config :asciinema, Asciinema.Emails.Mailer,
  tls_options: [
    cacerts: :public_key.cacerts_get(), 
    server_name_indication: ~c"#{System.get_env("SMTP_HOST")}",
    depth: 99,
    customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)]
  ]