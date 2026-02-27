import{_ as a,o as n,c as e,aj as i}from"./chunks/framework.DpVzuYkC.js";const k=JSON.parse('{"title":"HAProxy","description":"","frontmatter":{},"headers":[],"relativePath":"haproxy/index.md","filePath":"haproxy/README.md"}'),p={name:"haproxy/index.md"};function l(t,s,c,h,r,o){return n(),e("div",null,[...s[0]||(s[0]=[i(`<h1 id="haproxy" tabindex="-1">HAProxy <a class="header-anchor" href="#haproxy" aria-label="Permalink to “HAProxy”">​</a></h1><p><a href="https://www.haproxy.org/" target="_blank" rel="noreferrer">Office Web</a> - <a href="https://github.com/haproxy/haproxy" target="_blank" rel="noreferrer">Source</a> - <a href="https://hub.docker.com/_/haproxy" target="_blank" rel="noreferrer">Docker Image</a> - <a href="https://docs.haproxy.org/" target="_blank" rel="noreferrer">Document</a></p><hr><blockquote><p><a href="https://www.haproxy.org/" target="_blank" rel="noreferrer">HAProxy</a> 是一款免费、非常快速且可靠的反向代理，为基于 TCP 和 HTTP 的应用提供高可用性 、 负载均衡和代理服务。</p></blockquote><hr><h2 id="使用教程" tabindex="-1">使用教程 <a class="header-anchor" href="#使用教程" aria-label="Permalink to “使用教程”">​</a></h2><p>本教程参考自项目内的基础配置，涵盖了从基础 HTTP 到复杂反代场景的配置说明。</p><h3 id="_1-基础教程-绑定-80-端口-默认站" tabindex="-1">1. 基础教程：绑定 80 端口（默认站） <a class="header-anchor" href="#_1-基础教程-绑定-80-端口-默认站" aria-label="Permalink to “1. 基础教程：绑定 80 端口（默认站）”">​</a></h3><p>这是最简化的配置，适合作为入门。它将所有 80 端口的流量转发到后端的 Web 服务。</p><div class="language-config"><button title="Copy Code" class="copy"></button><span class="lang">config</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span>global</span></span>
<span class="line"><span>    log stdout format raw local0 info</span></span>
<span class="line"><span>    maxconn 4096</span></span>
<span class="line"><span></span></span>
<span class="line"><span>defaults</span></span>
<span class="line"><span>    log     global</span></span>
<span class="line"><span>    mode    http                        # 七层负载均衡模式</span></span>
<span class="line"><span>    option  httplog</span></span>
<span class="line"><span>    timeout connect 5s</span></span>
<span class="line"><span>    timeout client  50s</span></span>
<span class="line"><span>    timeout server  50s</span></span>
<span class="line"><span></span></span>
<span class="line"><span>frontend http-in</span></span>
<span class="line"><span>    bind *:80</span></span>
<span class="line"><span>    default_backend webservers</span></span>
<span class="line"><span></span></span>
<span class="line"><span>backend webservers</span></span>
<span class="line"><span>    balance roundrobin                  # 轮询算法</span></span>
<span class="line"><span>    # 健康检查：发送 HEAD 请求</span></span>
<span class="line"><span>    http-check connect</span></span>
<span class="line"><span>    http-check send meth HEAD uri / ver HTTP/1.1 hdr Host localhost</span></span>
<span class="line"><span>    http-check expect status 200,301,302</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    # 定义后端服务器</span></span>
<span class="line"><span>    server web1 web1:80 check inter 5s rise 2 fall 3</span></span>
<span class="line"><span>    server web2 web2:80 check inter 5s rise 2 fall 3</span></span></code></pre></div><hr><h3 id="_2-添加-443-证书支持-let-s-encrypt" tabindex="-1">2. 添加 443 证书支持（Let&#39;s Encrypt） <a class="header-anchor" href="#_2-添加-443-证书支持-let-s-encrypt" aria-label="Permalink to “2. 添加 443 证书支持（Let&#39;s Encrypt）”">​</a></h3><p>HAProxy 处理 HTTPS 需要将证书和私钥合并为一个 <code>.pem</code> 文件。</p><h4 id="证书准备-合并证书" tabindex="-1">证书准备 (合并证书) <a class="header-anchor" href="#证书准备-合并证书" aria-label="Permalink to “证书准备 (合并证书)”">​</a></h4><p>如果你使用 Let&#39;s Encrypt (Certbot/acme.sh)，你会得到 <code>fullchain.cer</code> 和 <code>private.key</code>。需要合并它们：</p><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">cat</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;example.com.fullchain.cer&quot;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;example.com.key&quot;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> &gt;</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;/etc/haproxy/certs/example.com.pem&quot;</span></span></code></pre></div><h4 id="配置更新" tabindex="-1">配置更新 <a class="header-anchor" href="#配置更新" aria-label="Permalink to “配置更新”">​</a></h4><div class="language-config"><button title="Copy Code" class="copy"></button><span class="lang">config</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span>frontend http-in</span></span>
<span class="line"><span>    bind *:80</span></span>
<span class="line"><span>    # 强制将所有特定域名的 HTTP 流量跳转到 HTTPS</span></span>
<span class="line"><span>    acl is_dash hdr(host) -i dash.4.fx4.cn</span></span>
<span class="line"><span>    http-request redirect scheme https code 301 if is_dash</span></span>
<span class="line"><span></span></span>
<span class="line"><span>frontend https-in</span></span>
<span class="line"><span>    # crt 后面可以指定具体的 pem 文件，也可以指定目录（自动根据域名匹配 SNI）</span></span>
<span class="line"><span>    bind *:443 ssl crt /etc/haproxy/certs/</span></span>
<span class="line"><span>    mode http</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    # 统计页面</span></span>
<span class="line"><span>    stats uri /stats</span></span>
<span class="line"><span>    stats enable</span></span>
<span class="line"><span>    stats auth admin:admin888</span></span>
<span class="line"><span>    stats refresh 10s</span></span>
<span class="line"><span>    stats show-legends</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    default_backend webservers</span></span></code></pre></div><hr><h3 id="_3-添加一个-api-服务" tabindex="-1">3. 添加一个 API 服务 <a class="header-anchor" href="#_3-添加一个-api-服务" aria-label="Permalink to “3. 添加一个 API 服务”">​</a></h3><p>通常 API 服务通过独立域名（如 <code>api.example.com</code>）或路径来区分。</p><div class="language-config"><button title="Copy Code" class="copy"></button><span class="lang">config</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span>frontend https-in</span></span>
<span class="line"><span>    bind *:443 ssl crt /etc/haproxy/certs/</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    # 定义 ACL 匹配规则</span></span>
<span class="line"><span>    acl host_api hdr(host) -i api.example.com</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    # 分发到不同的后端</span></span>
<span class="line"><span>    use_backend api_backend if host_api</span></span>
<span class="line"><span>    default_backend webservers</span></span>
<span class="line"><span></span></span>
<span class="line"><span>backend api_backend</span></span>
<span class="line"><span>    balance roundrobin</span></span>
<span class="line"><span>    server api_srv1 arcane:3552 check</span></span></code></pre></div><hr><h3 id="_4-添加-websocket-支持" tabindex="-1">4. 添加 WebSocket 支持 <a class="header-anchor" href="#_4-添加-websocket-支持" aria-label="Permalink to “4. 添加 WebSocket 支持”">​</a></h3><p>WebSocket 是长连接，需要配置 <code>timeout tunnel</code>，否则连接会在默认的超时到期后断开。</p><div class="language-config"><button title="Copy Code" class="copy"></button><span class="lang">config</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span>defaults</span></span>
<span class="line"><span>    # ... 其他配置 ...</span></span>
<span class="line"><span>    timeout tunnel 1h  # WebSocket 关键配置：建议设为 1h 或更大</span></span>
<span class="line"><span></span></span>
<span class="line"><span>backend arcane_backend</span></span>
<span class="line"><span>    balance roundrobin</span></span>
<span class="line"><span>    mode http</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    # 确保后端感知原始 Host</span></span>
<span class="line"><span>    http-request set-header Host %[req.hdr(Host)]</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    # 也可以在 backend 独立设置超时</span></span>
<span class="line"><span>    timeout tunnel 1h</span></span>
<span class="line"><span>    timeout client 1h</span></span>
<span class="line"><span>    timeout server 1h</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    server arcane arcane:3552 check inter 5s rise 2 fall 3</span></span></code></pre></div><hr><h3 id="_5-反代到-nginx-8080-端口-多域名" tabindex="-1">5. 反代到 Nginx（8080 端口，多域名） <a class="header-anchor" href="#_5-反代到-nginx-8080-端口-多域名" aria-label="Permalink to “5. 反代到 Nginx（8080 端口，多域名）”">​</a></h3><p>当 HAProxy 作为入口，后端是 Nginx 且有多个域名时，必须透传 <code>Host</code> 头。</p><div class="language-config"><button title="Copy Code" class="copy"></button><span class="lang">config</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span>frontend https-in</span></span>
<span class="line"><span>    bind *:443 ssl crt /etc/haproxy/certs/</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    # 定义多个域名的 ACL</span></span>
<span class="line"><span>    acl host_site1 hdr(host) -i site1.4.fx4.cn</span></span>
<span class="line"><span>    acl host_site2 hdr(host) -i site2.4.fx4.cn</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    use_backend nginx_backend if host_site1 || host_site2</span></span>
<span class="line"><span></span></span>
<span class="line"><span>backend nginx_backend</span></span>
<span class="line"><span>    balance roundrobin</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    # 【关键】保留原始 Host 头以避免 Nginx 虚拟主机识别出错</span></span>
<span class="line"><span>    http-request set-header Host %[req.hdr(Host)]</span></span>
<span class="line"><span></span></span>
<span class="line"><span>    # 反代到 Nginx 服务</span></span>
<span class="line"><span>    server nginx_srv nginx:8080 check inter 5s rise 2 fall 3</span></span></code></pre></div><hr><h2 id="脚本管理-deploy-sh" tabindex="-1">脚本管理 (deploy.sh) <a class="header-anchor" href="#脚本管理-deploy-sh" aria-label="Permalink to “脚本管理 (deploy.sh)”">​</a></h2><p>项目提供了一个 <code>deploy.sh</code> 脚本，用于自动化管理域名配置、证书合并以及服务重启。</p><h3 id="_1-环境准备" tabindex="-1">1. 环境准备 <a class="header-anchor" href="#_1-环境准备" aria-label="Permalink to “1. 环境准备”">​</a></h3><p>在 <code>.env</code> 文件中配置证书路径：</p><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 证书来源目录（包含 .key 和 .fullchain.cer）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">SOURCE_DIR</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">/path/to/your/certificates</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># PEM 存储目录（HAProxy 使用）</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">DEST_DIR</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">./certs</span></span></code></pre></div><h3 id="_2-常用操作" tabindex="-1">2. 常用操作 <a class="header-anchor" href="#_2-常用操作" aria-label="Permalink to “2. 常用操作”">​</a></h3><h4 id="添加域名" tabindex="-1">添加域名 <a class="header-anchor" href="#添加域名" aria-label="Permalink to “添加域名”">​</a></h4><p>自动在 <code>haproxy.cfg</code> 中添加 ACL、重定向规则，并重载服务：</p><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">./deploy.sh</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> example.com</span></span></code></pre></div><p><em>加上 <code>-g</code> 参数可同时触发证书合并：<code>./deploy.sh example.com -g</code></em></p><h4 id="删除域名" tabindex="-1">删除域名 <a class="header-anchor" href="#删除域名" aria-label="Permalink to “删除域名”">​</a></h4><p>从配置文件中移除相关 ACL 规则：</p><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">./deploy.sh</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> example.com</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -a</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> rm</span></span></code></pre></div><h4 id="证书维护-ssl" tabindex="-1">证书维护 (SSL) <a class="header-anchor" href="#证书维护-ssl" aria-label="Permalink to “证书维护 (SSL)”">​</a></h4><p>将 <code>SOURCE_DIR</code> 下的所有证书合并为 HAProxy 所需的 <code>.pem</code> 格式（<code>fullchain.cer</code> + <code>key</code>）：</p><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">./deploy.sh</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> -a</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> ssl</span></span></code></pre></div><h4 id="服务管理" tabindex="-1">服务管理 <a class="header-anchor" href="#服务管理" aria-label="Permalink to “服务管理”">​</a></h4><ul><li><strong>重载配置 (不宕机)</strong>：<code>./deploy.sh -a reload</code></li><li><strong>启动容器</strong>：<code>./deploy.sh -a up</code></li><li><strong>停止容器</strong>：<code>./deploy.sh -a down</code></li></ul><h3 id="_3-证书合并逻辑" tabindex="-1">3. 证书合并逻辑 <a class="header-anchor" href="#_3-证书合并逻辑" aria-label="Permalink to “3. 证书合并逻辑”">​</a></h3><p>脚本会扫描 <code>SOURCE_DIR</code> 下的 <code>.key</code> 文件，寻找匹配的 <code>.fullchain.cer</code>，合并后输出到 <code>DEST_DIR</code>。 例如：<code>domain.com.key</code> + <code>domain.com.fullchain.cer</code> -&gt; <code>domain.com.pem</code></p>`,51)])])}const b=a(p,[["render",l]]);export{k as __pageData,b as default};
