# ferron

[Office Web][1] - [Source][2] - [Docker Image][3] - [Docment][4]

---

> [ferron][1] 是针对速度、安全性和效率进行了优化的 Web 服务器。它用 Rust 编写，提供内存安全性和性能，使其成为现代网站的理想选择。

[1]:https://ferron.sh/
[2]:https://github.com/ferronweb/ferron
[3]:https://hub.docker.com/r/ferronserver/ferron
[4]:https://ferron.sh/docs

---

## 配置

### 官方原始的 `ferron.kdl`
```kdl
// See https://ferron.sh/docs/configuration-kdl for the configuration reference

// Include all domain-specific configurations.
// Each domain should have its own .kdl file in /etc/ferron.d/
// include "/etc/ferron.d/**/*.kdl"

// Global configuration.
//
// Here you can put configuration that applies to all hosts,
// and even to the web server itself.
globals {
  // Log requests and errors into log files
  log "/var/log/ferron/access.log"
  error_log "/var/log/ferron/error.log"
}

// Host configuration.
//
// Here you can put configuration that applies to a specific host,
// by default a catch-all ":80" host that applies to all hostnames and port 80 (HTTP).
//
// Replace ":80" with your domain name (pointing to your server) to use HTTPS.
// If you don't specify the paths to the TLS certificate and private key manually,
// Ferron will obtain a TLS certificate automatically (via Let's Encrypt by default).
:80 {
  // Serve static files
  root "/var/www/ferron"

  // Reverse proxy to a backend server
  //proxy "http://localhost:3000/"

  // Serve a PHP site with PHP-FPM (you would need to specify the webroot also used for serving static files)
  // Replace "unix:///run/php/php-fpm.sock" with your Unix socket URL
  //fcgi_php "unix:///run/php/php-fpm.sock"

  // If using Unix socket with PHP-FPM,
  // set the listener owner and group in the PHP pool configuration to the web server user (`ferron`, if you used installer for GNU/Linux)
  // For example:
  //   listen.owner = ferron
  //   listen.group = ferron
}
```

### 基础的 `ferron.kdl`
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

### 扩展配置
```bash
/etc/ferron # tree
.
├── ferron.kdl
├── http.d
│   ├── http_default.kdl
│   ├── https_default.kdl
└── ssl
    ├── default.crt
    └── default.key
```

1. 官方入口：`/etc/ferron.kdl`
```kdl
include "/etc/ferron/ferron.kdl"
```

2. 自定义入口：`/etc/ferron/ferron.kdl`
```kdl
include "/etc/ferron/http.d/*.kdl"

globals {
  log "/var/log/ferron/access.log"
  error_log "/var/log/ferron/error.log"
}
```

3. 80 端口和 443 端口示例：`/etc/ferron/http.d/example.com.kdl`
```kdl
// Host configuration for example.com
example.com:443 {
  auto_tls
  auto_tls_contact "admin@example.com" // Replace with your email address
  auto_tls_challenge "http-01"
  auto_tls_letsencrypt_production // 生产环境
  // auto_tls_letsencrypt_production #false // 测试环境
  auto_tls_cache "/etc/ferron/ssl/letsencrypt" // Specify cache directory for certificates

  // Reverse proxy to a backend server
  proxy "http://localhost:8989"
}

// HTTP configuration for example.com
example.com:80 {
  // Redirect HTTP to HTTPS
  status 301 location="https://example.com{path_and_query}"
}
```

4. 通用 80 端口入口（所有未配置的域名均走此）：`/etc/ferron/http.d/http_default.kdl`
```kdl
// /etc/ferron/http.d/http_default.kdl
*:80 {
  // This configuration handles all unbound domain accesses on port 80
  // The * wildcard matches all hostnames not explicitly defined elsewhere

  // Document root and index files
  root "/var/www/ferron"
  index "index.html" "index.htm"
}
```

5. 通用 443 端口入口（所有未配置的域名均走此）：`/etc/ferron/http.d/https_default.kdl`
```kdl
// /etc/ferron/http.d/https_default.kdl
*:443 {
  // This configuration handles all unbound domain accesses on port 443
  // The * wildcard matches all hostnames not explicitly defined elsewhere

  // Document root and index files
  root "/var/www/ferron"
  index "index.html" "index.htm"

  // Use self-signed certificates for default HTTPS access
  tls "/etc/ferron/ssl/dummy.crt" "/etc/ferron/ssl/dummy.key"
}
```
生成证书
```bash
openssl req -x509 -nodes -days 1 -newkey rsa:2048 -keyout ssl/dummy.key -out ssl/dummy.crt -subj "/CN="
```
