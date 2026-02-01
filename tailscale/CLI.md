# Tailscale CLI

> 此文档从[**官方 CLI 文档**](https://tailscale.com/kb/1080/cli)提取并转为简体中文。更多命令行查看 [**CLI_EXTRA.md**](CLI_EXTRA.md)。

Tailscale 客户端内置了一个命令行界面（CLI），您可以用它来管理和排查您在 Tailscale 网络（称为 tailnet）中的设备。

## 使用 Tailscale CLI

### Linux

在 Linux 上，CLI 是您与 Tailscale 交互的主要方式。`tailscale` 二进制文件通常已经位于您的 `$PATH` 中，因此可以直接运行：

```shell
tailscale <命令>
```

iOS 和 Android 不支持 CLI。

### Tab 补全

Tailscale CLI 支持对命令、标志和参数进行 Tab 补全。您可以使用 [`completion` 命令](#completion) 来配置补全功能。

```shell
tailscale completion <shell> [--flags] [--descs]
```

选择您的 shell，然后按照说明加载 Tailscale CLI 补全。

#### Bash

要为 Bash 加载 Tab 补全，请运行以下命令：

```shell
source <(tailscale completion bash)
```

要在 Linux 上为每个新会话加载补全，请运行以下命令，然后重新加载 shell：

```shell
tailscale completion bash > /etc/bash_completion.d/tailscale
```

## 命令参考

所有命令的通用标志：

- `--socket=<path>` tailscaled socket 的路径。

### up

将您的设备连接到 Tailscale，并在需要时进行认证。

```shell
tailscale up [flags]
```

不带任何标志运行 `tailscale up` 即可连接到 Tailscale。

常用标志：

- `--accept-routes` 接受其他节点广播的[子网路由](https://tailscale.com/kb/1019/subnets)。默认值取决于主机操作系统。对于 Windows、iOS、Android、macOS App Store 版以及 macOS 独立版，默认接受路由；其他平台默认不接受。
- `--advertise-exit-node` 声明本设备为[出口节点](https://tailscale.com/kb/1103/exit-nodes)，用于 tailnet 的出站互联网流量。默认不声明。
- `--advertise-routes=<ip>` 向整个 Tailscale 网络暴露物理[子网路由](https://tailscale.com/kb/1019/subnets)。
- `--exit-node=<ip|name>` 指定要使用的出口节点的 [Tailscale IP](https://tailscale.com/kb/1033/ip-and-dns-addresses) 或[机器名称](https://tailscale.com/kb/1098/machine-names)。要禁用出口节点，可传入空值：`--exit-node=`。
- `--exit-node-allow-lan-access` 允许客户端在使用出口节点时访问自己的本地局域网。默认不允许。
- `--force-reauth` 强制重新认证。
- `--snat-subnet-routes`（仅 Linux）禁用源 NAT。通常子网设备看到来自子网路由器的流量源地址。禁用源 NAT 后，目标机器能看到原始机器的局域网 IP 作为源地址。
- `--stateful-filtering` 为[子网路由器](https://tailscale.com/kb/1019/subnets)和[出口节点](https://tailscale.com/kb/1103/exit-nodes)启用有状态过滤。启用后，除非是来自该节点的已跟踪出站连接的回复，否则丢弃目的 IP 为其他节点的入站包。默认禁用。
- `--shields-up` [阻止 tailnet 内其他设备主动连接本设备](https://tailscale.com/kb/1072/client-preferences)。适合只发起出站连接的个人设备。
- `--ssh` 运行 [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh) 服务器，按照 tailnet 管理员定义的[访问策略](https://tailscale.com/kb/1018/acls)（或[默认策略](https://tailscale.com/kb/1192/acl-samples#allow-all-default-acl)）允许访问。默认 false。

完整标志列表请参考 [`tailscale up`](https://tailscale.com/kb/1241/tailscale-up) 主题。

### down

断开与 Tailscale 的连接。该命令相当于在 Tailscale 客户端中选择断开或退出。

```shell
tailscale down
```

断开后，您无法通过 Tailscale 访问其他设备。要重新连接，请再次运行不带标志的 `tailscale up`。

可用标志：

- `--accept-risk=<risk>` 接受风险并跳过确认，可选值：`lose-ssh`、`all` 或空字符串（不接受风险）。
- `--reason="<description>"` 当系统策略 `AlwaysOn.Enabled` 和 `AlwaysOn.OverrideWithReason` 启用时，指定断开原因（需加引号）。示例：`tailscale down --reason="DNS issues"`。

### bugreport

> `bugreport` 命令自 Tailscale v1.8 起可用。如果看不到该命令，请考虑[更新](https://tailscale.com/kb/1067/update)您的 Tailscale 客户端。

生成包含诊断信息的错误报告。

该命令通过在诊断日志中添加标记，便于 Tailscale 团队进行问题排查。

遇到连接问题时，在问题发生时立即在受影响设备上运行 `tailscale bugreport`。该命令会向诊断日志中打印一个随机标识符，您可将其分享给我们的团队。

标识符示例：

```shell
$ tailscale bugreport
BUG-1b7641a16971a9cd75822c0ed8043fee70ae88cf05c52981dc220eb96a5c49a8-20210427151443Z-fbcd4fd3a4b7ad94
```

此命令不分享任何可识别个人身份的信息，除非您主动分享 bug 标识符，否则不会被使用。

可用标志：

- `--diagnose` 在生成 `bugreport` 标识符后，向 Tailscale 日志打印更多系统详细信息，供支持团队查看。默认 `false`。
- `--record` 暂停后生成第二个 `bugreport`。先创建初始标识符，暂停期间重现问题，然后按回车生成第二个标识符。将两个标识符一起分享给团队。默认 `false`。

### cert

为主机生成 Let's Encrypt 证书和密钥文件，用于 tailnet 中的 [HTTPS 证书](https://tailscale.com/kb/1153/enabling-https)。

> 如果您想共享文件目录或反向代理 HTTP 服务，请改用 [`tailscale serve`](#serve) 命令。

```shell
tailscale cert hostname.tailscale.ts.net
```

或者，您可以指定保存证书和私钥的文件路径：

```shell
tailscale cert --cert-file=cert.pem --key-file=key.pem hostname.tailscale.ts.net
```

Let's Encrypt 证书有效期为 90 天，需要定期续期。当使用 `tailscale cert` 将证书保存到磁盘并手动移动到安装位置时，[`tailscaled` 守护进程](https://tailscale.com/kb/1278/tailscaled)不知道续期证书的放置位置，因此您需要自行负责续期。

如果证书由 Tailscale 自动处理（例如使用 [Caddy 集成](https://github.com/tailscale/caddy-tailscale)），则会自动续期，无需用户干预。

可用标志：

- `--cert-file=<cert>` 指定证书输出路径。
- `--key-file=<key>` 指定私钥输出路径。
- `--min-validity=<duration>` 请求证书至少剩余的有效期。`duration` 可被 [`time.ParseDuration()`](https://pkg.go.dev/time#ParseDuration) 解析，例如 `120h` 表示 5 天。
- `--serve-demo` 使用该证书在 `:443` 端口提供演示服务，而不是写入磁盘。

> `--min-validity` 标志可确保返回的证书至少还有指定时长的有效期。如果指定的时长超过 [Let's Encrypt 的证书寿命](https://letsencrypt.org/docs/faq#what-is-the-lifetime-for-let-s-encrypt-certificates-for-how-long-are-they-valid)，则使用 Let's Encrypt 的最大寿命。

### dns

`dns` 命令允许您访问 [Tailscale DNS 设置](https://tailscale.com/kb/1054/dns)。自 Tailscale v1.74.0 起可用。

子命令：

- `status` 打印本地 DNS 转发器配置以及 tailnet 范围的 [MagicDNS](https://tailscale.com/kb/1081/magicdns) 配置。
- `query` 使用本地 DNS 转发器执行 DNS 查询。自 Tailscale v1.76.0 起可用。

`status` 的可用标志：

- `--all` 输出高级调试信息。

### drive

使用 [Taildrive](https://tailscale.com/kb/1369/taildrive) 与您的 tailnet 共享目录。

```shell
tailscale drive share <name> <path>
tailscale drive rename <oldname> <newname>
tailscale drive unshare <name>
tailscale drive list
```

子命令：

- `share` 创建或修改共享。
- `rename` 重命名共享。
- `unshare` 移除共享。
- `list` 列出当前共享。

### completion

配置 Tailscale CLI 的 Tab 补全。

```shell
tailscale completion <subcommand> [flags]
```

子命令：

- `bash` 为 bash shell 配置补全。
- `zsh` 为 zsh shell 配置补全。
- `fish` 为 fish shell 配置补全。
- `powershell` 为 PowerShell 配置补全。

可用标志：

- `--flags=<true|false>` 是否建议标志（除了子命令）。默认 `true`。
- `--descs=<true|false>` 是否在建议中包含子命令描述。默认 `true`。

### configure

配置要包含在 tailnet 中的资源。

```shell
tailscale configure <subcommands>
```

子命令：

- `kubeconfig` (alpha) 配置 `kubectl` 使用 Tailscale 连接 Kubernetes 集群。
- `mac-vpn` 在 macOS [App Store 版](https://tailscale.com/kb/1065/macos-variants#mac-app-store-variant) 和 [独立版](https://tailscale.com/kb/1065/macos-variants#standalone-variant) 上安装或卸载 VPN 配置。
- `synology` 配置 Synology 以启用 Tailscale 所需的出站连接。
- `sysext` 在 macOS [独立版](https://tailscale.com/kb/1065/macos-variants#standalone-variant) 上激活、停用或管理 Tailscale [系统扩展](https://tailscale.com/kb/1340/macos-sysext) 状态。
- `systray` 管理 Linux 的 `systray` 客户端。

`kubeconfig` 的可用标志：

- `--http` 使用 HTTP 而非 HTTPS 连接认证代理。如果主机名参数中包含协议，则忽略此标志。

`mac-vpn` 的可用子命令：

- `install` 将 Tailscale VPN 配置写入 macOS 设置。
- `uninstall` 从 macOS 设置中删除 Tailscale VPN 配置。

`sysext` 的可用子命令：

- `activate` 在 macOS 中注册 Tailscale 系统扩展。
- `deactivate` 在 macOS 中停用 Tailscale 系统扩展。
- `status` 打印 Tailscale 系统扩展的启用状态。

`systray` 的可用标志：

- `--enable-startup=<init-system>` 为 init 系统安装启动脚本。目前仅支持 `systemd`。

示例：

- 配置本地 `kubeconfig` 文件以使用 Kubernetes 认证代理：

```shell
tailscale configure kubeconfig <hostname-or-fqdn>
```

- 配置 Synology 以启用出站连接：

```shell
tailscale configure synology
```

### exit-node

获取 tailnet 中 [出口节点](https://tailscale.com/kb/1103/exit-nodes) 的信息。

```shell
tailscale exit-node <subcommands>
```

可用子命令：

- `list` 列出 tailnet 中的出口节点。
- `suggest` 建议推荐的出口节点。

`list` 的可用标志：

- `--filter=<country>` 按国家过滤出口节点。

### file

访问并使文件可通过 [Taildrop](https://tailscale.com/kb/1106/taildrop) 共享。

```shell
tailscale file cp <files...> <target>:
tailscale file get <target-directory>
```

可用命令：

- `cp` 复制文件到主机。
- `get` 从 Tailscale 文件收件箱中取出文件。

`cp` 的可用标志：

- `--name=<name>` 使用备用文件名，尤其当 `<file>` 为 `-`（stdin）时有用。
- `--targets` 列出可能的 `cp` 目标。
- `--verbose` 详细输出。

`get` 的可用标志：

- `--conflict=<behavior>` 当目标目录中已存在同名文件时的行为：
  - `skip` 跳过冲突文件：保留在 Taildrop 收件箱并打印错误。获取非冲突文件。
  - `overwrite` 覆盖现有文件。
  - `rename` 写入带编号后缀的新文件名。
- `--loop` 循环运行 get，接收不断到达的文件。
- `--verbose` 详细输出。
- `--wait` 如果收件箱为空，等待文件到达。

### funnel

将内容和本地服务从您的 Tailscale 节点公开到互联网。

若仅限 tailnet 内部访问，请使用 [`serve`](#serve) 命令。

```shell
tailscale funnel <target>
tailscale funnel <subcommand> [flags] <args>
```

子命令：

- [`status`](https://tailscale.com/kb/1311/tailscale-funnel#get-the-status) 获取状态。
- [`reset`](https://tailscale.com/kb/1311/tailscale-funnel#reset-tailscale-funnel) 重置配置。

更多信息请参考 [`tailscale funnel`](https://tailscale.com/kb/1311/tailscale-funnel) 主题。

### ip

获取设备的 Tailscale IP 地址。

```shell
tailscale ip [flags] [<hostname>]
```

默认返回当前设备的 `100.x.y.z` [IPv4 地址](https://tailscale.com/kb/1033/ip-and-dns-addresses) 和 IPv6 地址。可使用 `-4` 或 `-6` 仅返回一种地址。

```shell
$ tailscale ip -4
100.121.112.23
```

也可查询其他设备：

```shell
$ tailscale ip raspberrypi
100.126.153.111
fd7a:115c:a1e0:ab12:4843:cd96:627e:9975
```

可用标志：

- `--4` 仅返回 IPv4 地址。
- `--6` 仅返回 IPv6 地址。
- `--1` 仅返回一个地址，优先 IPv4。

### licenses

获取开源许可信息。

```shell
tailscale licenses
```

### lock

管理 tailnet 的 [Tailnet Lock](https://tailscale.com/kb/1226/tailnet-lock)。

```shell
tailscale lock <subcommand> [flags] <args>
```

常用子命令：

- [`init`](https://tailscale.com/kb/1243/tailscale-lock#lock-init) 初始化 Tailnet Lock。
- [`status`](https://tailscale.com/kb/1243/tailscale-lock#lock-status) 输出 Tailnet Lock 状态。
- [`add`](https://tailscale.com/kb/1243/tailscale-lock#lock-add) 添加一个或多个受信任的签名密钥。
- [`remove`](https://tailscale.com/kb/1243/tailscale-lock#lock-remove) 移除一个或多个受信任的签名密钥。
- [`sign`](https://tailscale.com/kb/1243/tailscale-lock#lock-sign) 签名节点密钥并传输到协调服务器。

不带子命令和参数运行 `tailscale lock` 等同于 [`tailscale lock status`](https://tailscale.com/kb/1243/tailscale-lock#lock-status)。

完整子命令和标志列表请参考 [`tailscale lock`](https://tailscale.com/kb/1243/tailscale-lock) 主题。

### login

登录 Tailscale（并将此设备加入您的 Tailscale 网络）。有关登录的更多信息，请参考 [快速用户切换](https://tailscale.com/kb/1225/fast-user-switching)。

```shell
tailscale login [flags]
```

可用标志：

- `--accept-dns` 接受管理控制台的 [DNS 配置](https://tailscale.com/kb/1054/dns)。默认接受 DNS 设置。
- `--accept-routes` 接受其他节点广播的 [子网路由](https://tailscale.com/kb/1019/subnets)。默认值取决于主机操作系统。对于 Windows、iOS、Android、macOS App Store 版以及 macOS 独立版，默认接受路由；其他平台默认不接受。
- `--advertise-connector` 声明为 [应用连接器](https://tailscale.com/kb/1281/app-connectors)，用于 tailnet 的特定域名互联网流量。
- `--advertise-exit-node` 声明为 [出口节点](https://tailscale.com/kb/1103/exit-nodes)，用于 tailnet 的出站互联网流量。默认不声明。
- `--advertise-routes=<ip>` 向整个 Tailscale 网络暴露物理 [子网路由](https://tailscale.com/kb/1019/subnets)。
- `--advertise-tags=<tags>` 为本设备赋予标签权限。您必须在 [`"TagOwners"`](https://tailscale.com/kb/1337/policy-syntax#tag-owners) 中列出才能应用标签。
- `--auth-key=<key>` 提供 [认证密钥](https://tailscale.com/kb/1085/auth-keys) 以自动认证节点为您的用户账户。处理 `--auth-key` 的最佳实践请参考 [安全处理认证密钥](https://tailscale.com/kb/1595/secure-auth-key-cli)。
- `--client-id` 用于通过 [工作负载身份联合](https://tailscale.com/kb/1581/workload-identity-federation) 生成 [认证密钥](https://tailscale.com/kb/1085/auth-keys) 的客户端 ID。
- `--client-secret` 用于生成 [认证密钥](https://tailscale.com/kb/1085/auth-keys) 的 [OAuth 客户端](https://tailscale.com/kb/1215/oauth-clients) 密钥；如果以 `file:` 开头，则为包含密钥的文件路径。
- `--exit-node=<ip|name>` 指定要使用的出口节点的 [Tailscale IP](https://tailscale.com/kb/1033/ip-and-dns-addresses) 或 [机器名称](https://tailscale.com/kb/1098/machine-names)。要禁用出口节点，可传入空值：`--exit-node=`。
- `--exit-node-allow-lan-access` 允许客户端在使用出口节点时访问自己的本地局域网。默认不允许。
- `--hostname=<name>` 指定设备的自定义主机名（替代操作系统提供的名称）。注意：这会更改 [MagicDNS](https://tailscale.com/kb/1081/magicdns) 中的机器名称。
- `--id-token` 来自身份提供商的 ID 令牌，用于与控制服务器交换 [工作负载身份联合](https://tailscale.com/kb/1581/workload-identity-federation)；如果以 `file:` 开头，则为包含令牌的文件路径。
- `--audience` 请求身份提供商 ID 令牌时使用的受众，用于通过 [工作负载身份联合](https://tailscale.com/kb/1581/workload-identity-federation) 生成的认证密钥。
- `--login-server=<url>` 指定控制服务器的基础 URL，替代 `https://controlplane.tailscale.com`。如果使用 [**Headscale**](https://github.com/juanfont/headscale)，请使用您的 Headscale 实例 URL。
- `--netfilter-mode=<mode>` Netfilter 模式（可选值：`on`、`nodivert`、`off`）。详情请参考 [Tailscale netfilter 模式](https://tailscale.com/kb/1593/netfilter-modes)。
- `--nickname=<name>` 当前账户的 [昵称](https://tailscale.com/kb/1225/fast-user-switching#setting-a-nickname)。
- `--operator=<user>` 指定除 `root` 外的 Unix 用户名来操作 `tailscaled`。
- `--qr` 生成 Web 登录 URL 的二维码。默认不显示二维码。
- `--qr-format=<format>` 二维码格式：`small` 或 `large`。默认 `small`。
- `--stateful-filtering` 为 [子网路由器](https://tailscale.com/kb/1019/subnets) 和 [出口节点](https://tailscale.com/kb/1103/exit-nodes) 启用有状态过滤。启用后，除非是来自该节点的已跟踪出站连接的回复，否则丢弃目的 IP 为其他节点的入站包。默认禁用。
- `--shields-up` [阻止 tailnet 内其他设备主动连接本设备](https://tailscale.com/kb/1072/client-preferences)。适合只发起出站连接的个人设备。
- `--snat-subnet-routes` 对使用 `--advertise-routes` 广播的本地路由进行源 NAT。
- `--ssh` 运行 [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh) 服务器，按照 tailnet 管理员定义的 [访问策略](https://tailscale.com/kb/1018/acls)（或[默认策略](https://tailscale.com/kb/1192/acl-samples#allow-all-default-acl)）允许访问。默认 false。
- `--timeout=<duration>` 等待 Tailscale 服务初始化的最长时间。`duration` 可被 [`time.ParseDuration()`](https://pkg.go.dev/time#ParseDuration) 解析。默认 `0s`（无限等待）。
- `--unattended`（仅 Windows）以 [无人值守模式](https://tailscale.com/kb/1088/run-unattended) 运行，即使当前用户注销，Tailscale 仍保持运行。

### logout

断开 Tailscale 并使当前登录过期。下次运行 `tailscale up` 时需要重新认证设备。

```shell
tailscale logout
```

如果在 [临时节点](https://tailscale.com/kb/1111/ephemeral-nodes) 上运行 `tailscale logout`，该节点将立即从 tailnet 中移除。

可用标志：

- `--reason` 注销原因，如果系统策略要求。

### metrics

暴露并收集 [Tailscale 客户端指标](https://tailscale.com/kb/1482/client-metrics)，供第三方监控系统使用。

```shell
tailscale metrics
```

子命令：

- `print` 在当前终端显示客户端指标。
- `write` 将指标值写入文本文件。

### netcheck

获取当前物理网络状况报告，用于调试连接问题。

```shell
tailscale netcheck
```

输出示例：

```shell
Report:
* Time: 2025-03-13T16:35:03.336481Z
* UDP: true
* IPv4: yes, <ipv4-address>
* IPv6: yes, <ipv6-address>
* MappingVariesByDestIP: false
* PortMapping:
* Nearest DERP: Seattle
* DERP latency:
  - sea: 24.2ms  (Seattle)
  - sfo: 50.5ms  (San Francisco)
  - lax: 57.2ms  (Los Angeles)
  - den: 58.5ms  (Denver)
  - dfw: 63ms    (Dallas)
  - ord: 73.3ms  (Chicago)
```

（示例中 [DERP 服务器](https://tailscale.com/kb/1232/derp-servers) 列表被截断以节省空间。）

- `UDP` 显示当前网络是否启用 UDP 流量。若为 false，则 Tailscale 很可能无法建立点对点连接，将依赖 [加密 TCP 中继 (DERP)](https://tailscale.com/kb/1232/derp-servers)。
- `IPv4` 和 `IPv6` 显示您的公网 IP 地址及双栈支持情况。
- `MappingVariesByDestIP` 表示设备是否处于根据目标变化的复杂 NAT 后面。
- `HairPinning` 表示路由器是否支持从局域网端点回环到局域网的全局映射 IPv4 地址/端口。
- `PortMapping` 列出路由器上存在的三种端口映射服务：UPnP、NAT-PMP、PCP。
- `DERP latency` 和 `Nearest DERP` 显示到 [加密 TCP 中继 (DERP)](https://tailscale.com/kb/1232/derp-servers) 的延迟，最低延迟（“最近”）的服务器将被用于流量。

若某些字段为空，表示 Tailscale 无法测量该网络属性。

`tailscale netcheck` 的所有信息也可在管理控制台的 [Machines](https://login.tailscale.com/admin/machines) 页面中查看，选择特定设备即可。

可用标志：

- `--every=<duration>` 若非零，则按给定频率进行增量报告。
- `--format=<format>` 输出格式：空（人类可读）、`json` 或 `json-line`。
- `--verbose` 详细日志。

### nc

连接到主机的端口，并连接 stdin/stdout。

```shell
tailscale nc <hostname-or-IP> <port>
```

### ping

仅通过 Tailscale 尝试 ping 另一设备。

普通 `ping` 命令通常能在 Tailscale 上正常工作，但 `tailscale ping` 提供更多 Tailscale 连接细节，便于排查连接问题。

```shell
tailscale ping <hostname-or-ip>
```

可使用 [100.x.y.z 地址](https://tailscale.com/kb/1033/ip-and-dns-addresses) 或 [机器名称](https://tailscale.com/kb/1098/machine-names) 调用。

可用标志：

- `--c` 发送的最大 ping 次数。默认 10。
- `--icmp`, `--icmp=false` 执行 ICMP 级 ping（通过 WireGuard，但不经过本地主机 OS 协议栈）。默认 false。
- `--peerapi`, `--peerapi=false` 尝试访问对端的 PeerAPI HTTP 服务器。默认 false。
- `--size=<size>` ping 消息大小（仅适用于默认 ping）。0 表示最小大小。
- `--tsmp`, `--tsmp=false` 执行 TSMP 级 ping（通过 WireGuard，但不经过任一主机 OS 协议栈）。默认 false。
- `--timeout=<duration>` 放弃 ping 前的最长等待时间。`duration` 可被 [`time.ParseDuration()`](https://pkg.go.dev/time#ParseDuration) 解析。默认 `5s`。
- `--until-direct`, `--until-direct=false` 一旦建立直接路径即停止。默认 true。
- `--verbose`, `--verbose=false` 显示详细输出。默认 false。

> `tailscale ping` 命令支持 [四种 ping 消息类型](https://tailscale.com/kb/1465/ping-types)。

### serve

在 tailnet 内从您的 Tailscale 节点提供内容和本地服务。

若要公开到互联网，请使用 [`funnel`](#funnel) 命令。

```shell
tailscale serve <target>
tailscale serve <subcommand> [flags] <args>
```

子命令：

- [`status`](https://tailscale.com/kb/1242/tailscale-serve#get-the-status) 获取状态。
- [`reset`](https://tailscale.com/kb/1242/tailscale-serve#reset-tailscale-serve) 重置配置。

更多信息请参考 [`tailscale serve`](https://tailscale.com/kb/1242/tailscale-serve) 主题。

### set

更改指定的偏好设置。

与 [`tailscale up`](#up) 不同，该命令无需提供完整的期望设置集，只更新您明确指定的设置。没有默认值。注意：在使用 [快速用户切换](https://tailscale.com/kb/1225/fast-user-switching) 时，更改仅适用于当前连接的 tailnet。

```shell
tailscale set [flags]
```

可用标志：

- `--accept-dns` 接受管理控制台的 [DNS 配置](https://tailscale.com/kb/1054/dns)。
- `--accept-risk=<risk>` 接受风险并跳过确认，可选值：`lose-ssh`、`all` 或空字符串（不接受风险）。
- `--accept-routes`, `--accept-routes=false` 接受其他节点广播的 [子网路由](https://tailscale.com/kb/1019/subnets)。默认值取决于主机操作系统。对于 Windows、iOS、Android、macOS App Store 版以及 macOS 独立版，默认接受路由；其他平台默认不接受。
- `--advertise-connector` 声明为 [应用连接器](https://tailscale.com/kb/1281/app-connectors)，用于 tailnet 的特定域名互联网流量。
- `--advertise-exit-node`, `--advertise-exit-node=false` 声明为出口节点，用于 tailnet 的互联网流量。
- `--advertise-routes=<ip>` 向整个 Tailscale 网络暴露物理 [子网路由](https://tailscale.com/kb/1019/subnets)。这是一个逗号分隔的字符串，例如 "10.0.0.0/8,192.168.0.0/24"，或空字符串表示不广播路由。
- `--auto-update`, `--auto-update=false` 启用或禁用客户端的 [自动更新](https://tailscale.com/kb/1067/update#auto-updates)。
- `--exit-node=<ip|name>` 指定要使用的出口节点的 [Tailscale IP](https://tailscale.com/kb/1033/ip-and-dns-addresses) 或 [机器名称](https://tailscale.com/kb/1098/machine-names)。也可使用 `--exit-node=auto:any` 跟踪推荐出口节点，并在可用出口节点或网络条件变化时自动切换。要禁用出口节点，可传入空值：`--exit-node=`。
- `--exit-node-allow-lan-access`, `--exit-node-allow-lan-access=false` 允许客户端在使用出口节点时访问自己的局域网。
- `--hostname=<name>` 指定设备的自定义主机名（替代操作系统提供的名称）。注意：这会更改 [MagicDNS](https://tailscale.com/kb/1081/magicdns) 中的机器名称。
- `--netfilter-mode=<mode>` Netfilter 模式（可选值：`on`、`nodivert`、`off`）。详情请参考 [Tailscale netfilter 模式](https://tailscale.com/kb/1593/netfilter-modes)。
- `--nickname=<name>` 当前账户的 [昵称](https://tailscale.com/kb/1225/fast-user-switching#setting-a-nickname)。
- `--operator=<user>` 指定除 `root` 外的 Unix 用户名来操作 `tailscaled`。
- `--relay-server-port=<port>` 指定接受对端中继连接的 UDP 端口。`0` 表示随机选择未使用端口，空字符串表示禁用中继服务器功能。详情请参考 [Tailscale Peer Relays](https://tailscale.com/kb/1591/peer-relays)。
- `--relay-server-static-endpoints` 为 [Tailscale Peer Relays](https://tailscale.com/kb/1591/peer-relays) 使用静态端点。
- `--report-posture` 允许管理平面收集 [设备姿态](https://tailscale.com/kb/1288/device-posture) 信息。
- `--shields-up`, `--shields-up=false` [阻止 tailnet 内其他设备主动连接本设备](https://tailscale.com/kb/1072/client-preferences)。适合只发起出站连接的个人设备。
- `--snat-subnet-routes` 对使用 `--advertise-routes` 广播的本地路由进行源 NAT。
- `--ssh`, `--ssh=false` 运行 [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh) 服务器，按照 tailnet 管理员定义的 [访问策略](https://tailscale.com/kb/1018/acls)（或[默认策略](https://tailscale.com/kb/1192/acl-samples#allow-all-default-acl)）允许访问。
- `--stateful-filtering` 对转发的包（子网路由器、出口节点等）应用有状态过滤。
- `--update-check` 通知可用 Tailscale 更新。
- `--webclient`, `--webclient=false` 在后台持久暴露 [Web 界面](https://tailscale.com/kb/1325/device-web-interface) 到 tailnet，监听端口 `:5252`。

### ssh

建立到 Tailscale 机器的 [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh) 会话。

您通常可以使用普通 `ssh` 命令或其他 SSH 客户端连接 Tailscale 机器。但当本地节点处于 [userspace-networking 模式](https://tailscale.com/kb/1177/kernel-vs-userspace-routers#userspace-netstack-mode) 且无法直连时，请使用 `tailscale ssh`。它会设置 SSH `ProxyCommand` 通过本地 `tailscaled` 守护进程连接。您也可以在 [kernel 模式](https://tailscale.com/kb/1177/kernel-vs-userspace-routers#kernel-mode) 下使用 `tailscale ssh`。

`tailscale ssh` 命令会自动将目标服务器的 SSH 主机密钥与通过 Tailscale 协调服务器广播的节点 SSH 主机密钥进行比对。

```shell
tailscale ssh <args>
```

`<args>` 为以下形式之一：

- `host` 目标服务器。交互式会话会提示您输入用户名。
- `user@host` 会话用户名和目标服务器。

对于两种形式，`host` 可以是目标服务器的 [MagicDNS](https://tailscale.com/kb/1081/magicdns) 名称（即使本地节点设置了 `--accept-dns=false`），也可以是目标服务器的 [Tailscale IP 地址](https://tailscale.com/kb/1033/ip-and-dns-addresses)。

> 在沙盒化的 macOS 构建中无法使用 `tailscale ssh`——请使用普通 `ssh` 客户端。

### status

获取与其他 Tailscale 设备的连接状态。

```shell
tailscale status
```

该命令返回人类可读的简洁表格：

```text
1           2         3           4         5
100.1.2.3   device-a  apenwarr@   linux     active; direct <ip-port>, tx 1116 rx 1124
100.4.5.6   device-b  crawshaw@   macOS     active; relay <relay-server>, tx 1351 rx 4262
100.7.8.9   device-c  danderson@  windows   idle; tx 1214 rx 50
100.0.1.2   device-d  ross@       iOS       -
```

从左到右各列含义：

- 第 1 列：[Tailscale IP](https://tailscale.com/kb/1015/100.x-addresses)，可用于连接设备。
- 第 2 列：设备的 [机器名称](https://tailscale.com/kb/1098/machine-names)。若启用 [MagicDNS](https://tailscale.com/kb/1081/magicdns)，也可使用此名称连接。
- 第 3 列：设备所有者的电子邮件地址。
- 第 4 列：设备操作系统。
- 第 5 列：当前连接状态。

连接状态（第 5 列）使用三种术语：

- `active` 表示当前正在与该设备发送/接收流量。同时显示连接类型：`direct`、`relay` 或 `peer-relay`。
  - `direct` 时包含对端 IP 地址。
  - `relay` 时包含 [DERP 服务器](https://tailscale.com/kb/1232/derp-servers) 的城市代码（nyc、fra、tok、syd 等）。
  - `peer-relay` 时包含对端中继的 Tailscale IP 和使用的 VNI（虚拟网络接口）。
- `idle` 表示当前未与该设备发送/接收流量。
- `-` 表示从未与该设备发送/接收过流量。

`active` 和 `idle` 状态还会显示 `tx`/`rx` 值，表示已发送（`tx`）和接收（`rx`）的字节数。

使用 `--json` 标志运行 `tailscale status` 会返回机器可读的 JSON 响应：

```shell
tailscale status --json
```

与普通 `tailscale status` 不同，此标志提供 tailnet 中对端和用户的详细列表，非常适合自动化任务，并包含设备的额外元数据。

结合 [`jq`](https://stedolan.github.io/jq) 可自动化网络数据收集。例如，以下命令统计并排序 Tailscale 对端连接的 relay 服务器：

```shell
tailscale status --json | jq -r '.Peer[].Relay | select(.!="")' | sort | uniq -c | sort -nr
```

可用标志：

- `--active` 仅过滤有活跃会话的对端（Web 模式下不适用）。
- `--browser` 在 Web 模式下打开浏览器（默认 `true`）。
- `--header` 在表格格式中显示列标题（默认 `false`）。
- `--json` 以 JSON 格式输出（注意：格式可能变更）。
- `--listen=<address>` Web 模式的监听地址；端口 0 表示自动（默认 `127.0.0.1:8384`）。
- `--peers` 显示对端状态（默认 `true`）。
- `--self` 显示本地机器状态（默认 `true`）。
- `--web` 运行 Web 服务器并显示状态的 HTML 页面。

### switch

切换到其他 Tailscale 账户。有关切换账户的更多信息，请参考 [快速用户切换](https://tailscale.com/kb/1225/fast-user-switching)。

```shell
tailscale switch <account> [flags]
```

示例：

- 切换到 `alice@example.com` 账户：

```shell
tailscale switch alice@example.com
```

- 切换到昵称为 "work" 的账户：

```shell
tailscale switch work
```

可用标志：

- `--list` 列出可用账户。

子命令：

- `remove <id>` 从本地机器移除 Tailscale 账户。此操作不会删除账户本身，但将无法再切换到该账户。您可通过重新登录添加回来。此命令目前处于 alpha 阶段，未来可能变更。

### syspolicy

列出、重新加载系统策略，或检查与 tailnet 配置的 [系统策略](https://tailscale.com/kb/1315/mdm-keys) 相关的错误。

```shell
tailscale syspolicy
```

子命令：

- `list` 显示系统策略、重新加载系统策略，或探索设备上配置的 [系统策略](https://tailscale.com/kb/1315/mdm-keys) 相关错误。
- `reload` 强制 Tailscale 客户端重新加载并应用设备上的系统策略设置。

可用标志：

- `--json` 返回机器可读的 JSON 响应。

### systray

> `systray` 命令适用于 Linux 客户端，目前处于 [beta](https://tailscale.com/kb/1167/release-stages#beta) 阶段，自 Tailscale v1.88 起可用。

运行 Linux 桌面客户端的 [系统托盘（systray）应用](https://tailscale.com/kb/1597/linux-systray)，以访问快速用户切换、选择出口节点等常用操作。

```shell
tailscale systray
```

> 请勿使用超级用户权限运行 `tailscale systray`（即 `sudo tailscale systray`），因为 systray 未设计为以 root 身份运行，命令将失败。

### update

> `update` 命令在以下平台可用：Windows 和 Ubuntu/Debian Linux 自 Tailscale v1.36 起，Mac App Store 版和 Synology 自 v1.48.0 起，QNAP 和 macOS [独立版](https://tailscale.com/kb/1065/macos-variants#standalone-variant) 自 v1.54.0 起。如果您在这些操作系统上未看到此命令，请考虑[更新 Tailscale 客户端](https://tailscale.com/kb/1067/update)。

将 Tailscale 客户端更新到最新版本或指定版本。

```shell
tailscale update [flags]
```

可用标志：

- `--dry-run` 显示更新将执行的操作，但不实际执行，也不提示开始更新。
- `--track` 检查更新的轨道，可选 `stable` 或 [`unstable`](https://tailscale.com/kb/1083/install-unstable)。未指定时，使用客户端当前生效的轨道。
- `--version` 指定用于更新或降级的明确版本。不能同时使用 `--track` 和 `--version`。macOS 客户端不支持此标志。
- `--yes` 无交互提示执行更新。默认 false。

如果您降级到不支持 `tailscale update` 功能的版本，将无法使用 `tailscale update` 返回上一版本。您需要[不使用 CLI 的方式进行更新](https://tailscale.com/kb/1067/update)。

要查看客户端当前版本，请运行 [`tailscale version`](#version)。

示例：

更新到当前轨道（stable 或 unstable，取决于您当前运行的版本）的最新版本：

```shell
tailscale update
```

无交互提示更新到当前轨道最新版本：

```shell
tailscale update --yes
```

更新到 Tailscale v1.34：

```shell
tailscale update --version=1.34.0
```

更新到最新不稳定版本：

```shell
tailscale update --track=unstable
```

### version

打印 Tailscale 版本。

```shell
tailscale version [flags]
```

可用标志：

- `--daemon` 同时打印本地节点的守护进程版本。默认 false。
- `--json` 返回机器可读的 JSON 响应。
- `--upstream` 打印来自 `pkgs.tailscale.com` 的最新上游发布版本。默认 false。

运行 `tailscale version` 还会打印其他信息，包括 Go 版本。示例输出：

```shell
tailscale version
1.72.0
  tailscale commit: 9a0f00ea8ed08d1a94b357fb232ac9d44a512664
  other commit: 387e0b40ad87031fb4444372ee80a97156e8deb9
  go version: go1.22.5
```

### web

启动用于控制 `tailscaled` 守护进程的 Web 服务器。在 CLI 或原生应用不方便的场景（例如 NAS 设备）下很有用。

```shell
tailscale web [flags]
```

可用标志：

- `--cgi=<true|false>` 以 CGI 脚本方式运行 Web 服务器。默认 false。
- `--listen=<ip|name>` 设置监听地址。端口 `0` 表示自动。默认 `localhost:8088`。
- `--origin=<hostname>` Web UI 被服务的来源（用于反向代理或 CGI 场景）。
- `--prefix=<string>` 为请求添加的 URL 前缀（用于 CGI 或反向代理）。
- `--readonly` 以只读模式运行 Web 服务器。

### whois

查询 Tailscale IP 对应的机器和用户。

```shell
tailscale whois ip[:port]
```

对于用户设备，返回：

```text
Machine:
  Name:
  ID:
  Addresses:
  AllowedIPs:
User:
  Name:
  ID:
Capabilities:
```

对于带标签的设备，返回：

```text
Machine:
  Name:
  ID:
  Addresses:
  AllowedIPs:
  Tags:
Capabilities:
```

各字段含义：

- `Machine`, `Name`：设备的 [机器名称](https://tailscale.com/kb/1098/machine-names)。若启用 [MagicDNS](https://tailscale.com/kb/1081/magicdns)，也可使用此名称连接。
- `Machine`, `ID`：设备的 [节点 ID](https://tailscale.com/kb/1155/terminology-and-concepts#node)。
- `Machine`, `Addresses`：[Tailscale IP](https://tailscale.com/kb/1015/100.x-addresses)，可用于连接设备。
- `Machine`, `AllowedIPs`：设备可用的子网路由。
- `Machine`, `Tags`：设备所属的标签。
- `User`, `Name`：设备所有者的电子邮件地址。
- `User`, `ID`：用户的唯一 ID。
- `Capabilities`：设备的权限。

使用 `--json` 标志运行 `tailscale whois` 将返回机器可读的 JSON 响应。（注意：`--json` 选项必须放在 `ip[:port]` 参数之前。）

```shell
tailscale whois --json ip[:port]
```

可用标志：

- `--json` 以 JSON 格式输出。
- `--proto=<proto>` WhoIs 请求的协议：`tcp` 或 `udp`；为空表示两者均支持。

### appc-routes

打印当前 [应用连接器](https://tailscale.com/kb/1281/app-connectors) 路由状态。

默认情况下，该命令打印应用连接器配置中设置的域名以及每个域名已学习的路由数量。

```shell
tailscale appc-routes [flags]
```

可用标志：

- `--all` 打印已学习域名和路由，以及额外策略配置的路由。
- `--map` 打印已学习域名的映射。
- `--n` 打印本节点广播的路由总数。
