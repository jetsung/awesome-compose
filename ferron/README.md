# ferron

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [ferron][1] 是针对速度、安全性和效率进行了优化的 Web 服务器。它用 Rust 编写，提供内存安全性和性能，使其成为现代网站的理想选择。

[1]:https://ferron.sh/
[2]:https://github.com/ferronweb/ferron
[3]:https://hub.docker.com/r/ferronserver/ferron
[4]:https://ferron.sh/docs

---

- `ferron.kdl`
```kdl
// See https://ferron.sh/docs/configuration-kdl for the configuration reference

// Include all domain-specific configurations.
// Each domain should have its own .kdl file in /etc/ferron.d/
include "/etc/ferron.d/**/*.kdl"

// Global configuration.
//
// Here you can put configuration that applies to all hosts,
// and even to the web server itself.
globals {
  // Log requests and errors into log files
  log "/var/log/ferron/access.log"
  error_log "/var/log/ferron/error.log"
}
```

- `example.com.kdl`
```kdl
// Global settings for example.com
globals {
    auto_tls
    auto_tls_contact "admin@example.com" // Replace with your email address
    auto_tls_challenge "http-01"
    auto_tls_letsencrypt_production #false // Use staging environment
}

// Host configuration for example.com
"example.com" {
  // Reverse proxy to a backend server
  proxy "http://localhost:8989"
}
```
