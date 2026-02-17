import{_ as a,o as i,c as n,aj as e}from"./chunks/framework.DpVzuYkC.js";const c=JSON.parse('{"title":"Memos","description":"","frontmatter":{},"headers":[],"relativePath":"memos/index.md","filePath":"memos/README.md"}'),t={name:"memos/index.md"};function l(h,s,p,r,k,d){return i(),n("div",null,[...s[0]||(s[0]=[e(`<h1 id="memos" tabindex="-1">Memos <a class="header-anchor" href="#memos" aria-label="Permalink to “Memos”">​</a></h1><p><a href="https://www.usememos.com/" target="_blank" rel="noreferrer">Office Web</a> - <a href="https://github.com/usememos/memos" target="_blank" rel="noreferrer">Source</a> - <a href="https://hub.docker.com/r/neosmemo/memos" target="_blank" rel="noreferrer">Docker Image</a> - <a href="https://www.usememos.com/docs" target="_blank" rel="noreferrer">Document</a></p><hr><blockquote><p><a href="https://www.usememos.com/" target="_blank" rel="noreferrer">Memos</a> 是一个现代、开源、自托管的知识管理和笔记平台，专为注重隐私的用户和组织而设计。Memos 提供了一个轻量级但功能强大的解决方案，用于捕获、组织和共享想法，具有全面的 Markdown 支持和跨平台可访问性。</p></blockquote><hr><h2 id="设置" tabindex="-1">设置 <a class="header-anchor" href="#设置" aria-label="Permalink to “设置”">​</a></h2><h3 id="环境变量" tabindex="-1">环境变量 <a class="header-anchor" href="#环境变量" aria-label="Permalink to “环境变量”">​</a></h3><div class="language-bash"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark" style="--shiki-light:#24292e;--shiki-dark:#e1e4e8;--shiki-light-bg:#fff;--shiki-dark-bg:#24292e;" tabindex="0" dir="ltr"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 启用演示模式</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEMOS_DEMO</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">false</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 绑定地址</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEMOS_ADDR</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 绑定端口</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEMOS_PORT</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">8081</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Unix 套接字路径</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEMOS_UNIX_SOCK</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 数据目录</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEMOS_DATA</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">auto</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 数据库驱动</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEMOS_DRIVER</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">sqlite</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 数据库 DSN</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEMOS_DSN</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 公共实例 URL</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># Host, X-Forwarded-Proto, X-Forwarded-For</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MEMOS_INSTANCE_URL</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span></span></code></pre></div><p>若启用 OIDC 方式登录，则需要配置</p><table tabindex="0"><thead><tr><th>名称</th><th>映射字段</th><th>描述</th></tr></thead><tbody><tr><td>标识符（Identifier）</td><td>preferred_username</td><td>用户名</td></tr><tr><td>显示名称</td><td>nickname</td><td>显示名称</td></tr><tr><td>邮箱</td><td>email</td><td>邮箱</td></tr></tbody></table>`,10)])])}const E=a(t,[["render",l]]);export{c as __pageData,E as default};
