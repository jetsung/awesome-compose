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

- `example.com.kdl` 443
```bash
// Host configuration for example.com
example.com:443 {
  auto_tls
  auto_tls_contact "admin@example.com" // Replace with your email address
  auto_tls_challenge "http-01"
  auto_tls_letsencrypt_production // 生产环境
  // auto_tls_letsencrypt_production #false // 测试环境
  auto_tls_cache "/var/lib/ferron/letsencrypt" // Specify cache directory for certificates

  // Reverse proxy to a backend server
  proxy "http://localhost:8989"
}
```

- `example.com.kdl` 80 跳转至 443
```bash
// HTTP configuration for example.com
example.com:80 {
  // Redirect HTTP to HTTPS
  status 301 location="https://example.com{path_and_query}"
}
```

- 80 端口
```bash
// /etc/ferron.d/http_default.kdl
*:80 {
  // This configuration handles all unbound domain accesses on port 80
  // The * wildcard matches all hostnames not explicitly defined elsewhere

  // Document root and index files
  root "/data/wwwroot/default"
  index "index.html" "index.htm"
}
```

- 443 端口
```bash
// /etc/ferron.d/https_default.kdl
*:443 {
  // This configuration handles all unbound domain accesses on port 443
  // The * wildcard matches all hostnames not explicitly defined elsewhere

  // Document root and index files
  root "/data/wwwroot/default"
  index "index.html" "index.htm"

  // Use self-signed certificates for default HTTPS access
  tls "/etc/ferron.d/ssl/default.crt" "/etc/ferron.d/ssl/default.key"
}
```
