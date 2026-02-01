# [tailscale funnel command](https://tailscale.com/kb/1311/tailscale-funnel)

> **注意**：Tailscale Funnel 和 Tailscale Serve 的 CLI 命令在 Tailscale 客户端 1.52 版本中已更改。如果您在之前的版本中使用过 Funnel 或 Serve，建议查看 CLI 文档。

`tailscale funnel` 允许您通过互联网共享本地服务。您也可以选择使用 [Tailscale Serve](https://tailscale.com/kb/1312/serve)，通过 [`tailscale serve`](https://tailscale.com/kb/1242/tailscale-serve) 命令将共享限制在您的 tailnet 内。

```shell
tailscale funnel [flags] <target>
```

子命令：

- [`status`](#get-the-status) 获取状态
- [`reset`](#reset-tailscale-funnel) 重置配置

要探索各种用例和示例，请参阅 [Tailscale Funnel 示例](https://tailscale.com/kb/1247/funnel-examples)。

## Funnel 命令标志

可用标志：

- `--bg` 确定命令是否应作为后台进程运行。
- `--https=<port>` 在指定端口暴露 HTTPS 服务器（默认）。
- `--proxy-protocol=<version>` 用于 TCP 转发的 PROXY 协议版本（1 或 2）。
- `--set-path=<path>` 将指定路径附加到访问底层服务的基础 URL。
- `--tcp=<port>` 在指定端口暴露 TCP 转发器以转发 TCP 数据包。
- `--tls-terminated-tcp=<port>` 在指定端口暴露 TLS 终止的 TCP 转发器以转发 TCP 数据包。
- `--yes` 无需交互式提示即可更新。

`tailscale funnel` 命令接受一个目标，该目标可以是文件、目录、文本，或最常见的是本地计算机上运行的服务的位置。本地服务的位置可以表示为端口号（例如 `3000`）、部分 URL（例如 `localhost:3000`）或包含路径的完整 URL（例如 `tls-terminated-tcp://localhost:3000/foo`）。

## 使用 HTTPS 和 HTTP 服务器

```shell
tailscale funnel --https=<port> <target> [off]
```

`funnel` 提供一个 HTTPS 服务器，有几种模式：反向代理、文件服务器和静态文本服务器。HTTPS 流量使用自动配置的 TLS 证书进行保护。默认情况下，终止由您节点的 Tailscale 守护进程本身完成。

- `--https=<port>` 指定要监听的端口。对于 Funnel，您必须使用允许的端口之一：`443`、`8443` 或 `10000`。

- `--set-path` 是一个斜杠分隔的 URL 路径。根级挂载点将只是 `/`，并且将通过向 `https://my-node.example.ts.net/` 发出请求来匹配。有关这些路径模式如何匹配的更多信息，请参阅 Go [ServeMux](https://pkg.go.dev/net/http#ServeMux) 文档。我们的挂载点行为类似。

- `<target>` Funnel 提供 4 个内容服务选项：HTTP 反向代理、文件、目录和静态文本。反向代理允许您将请求转发到本地 HTTP Web 服务器。提供本地文件路径可以提供服务文件或文件目录的能力。静态文本服务主要用于调试目的，并提供静态响应。

  - **反向代理**

    要作为本地后端的反向代理，请提供 `<target>` 参数的位置。本地服务的位置可以表示为端口号（例如 `3000`）、部分 URL（例如 `localhost:3000`）或包含路径的完整 URL（例如 `tls-terminated-tcp://localhost:3000/foo`）。请注意，目前只有 `http://127.0.0.1` 支持代理。

    示例：`tailscale funnel localhost:3000`

  - **文件服务器**

    提供您希望服务的文件或文件目录的完整绝对路径。如果指定了目录，这将呈现一个简单的目录列表，其中包含指向文件和子目录的链接。

    示例：`tailscale funnel /home/alice/blog/index.html`

    由于 macOS 应用沙盒限制，此选项仅在使用 Tailscale 的[开源版本](https://tailscale.com/kb/1065/macos-variants)时可用。如果您通过 Mac App Store 或作为独立版本系统扩展在 macOS 上安装了 Tailscale，您可以使用 Funnel 共享端口，但不能共享文件或目录。

  - **静态文本服务器**

    将 `text:<value>` 指定为 `<target>` 会配置一个简单的静态纯文本服务器。

    示例：`tailscale funnel text:"Hello, world!"`

## 使用 PROXY 协议

```shell
tailscale funnel --proxy-protocol=<version> <target>
```

> **注意**：对于大多数情况，用户可能会使用版本 `2`。

[PROXY 协议](https://www.haproxy.com/blog/use-the-proxy-protocol-to-preserve-a-clients-ip-address)是一种最小的网络协议，用于保留有关代理连接的信息（通常是源 IP 地址），通过代理或负载均衡器传递到后端目标。这使您使用 Funnel 公开的服务能够确定连接客户端的原始 IP 地址和端口。

例如：

```shell
$ tailscale funnel --proxy-protocol=2 --tls-terminated-tcp=443 tcp://127.0.0.1:9899
Available on the internet:

|-- tcp://funnel-test.example.ts.net:443 (TLS terminated, PROXY protocol v2)
|-- tcp://100.101.102.103:443
|-- tcp://[fd7a:115c:a1e0::1111:2222]:443
|---> tcp://127.0.0.1:9899

Press Ctrl+C to exit.
```

后端（运行在 `localhost:9899`）然后通过 PROXY 协议获取原始源 IP 和端口。

## 使用 TCP 转发器

```shell
tailscale funnel --tcp=<port> tcp://localhost:<local-port> [off]
tailscale funnel --tls-terminated-tcp=<port> tcp://localhost:<local-port> [off]
```

`funnel` 命令提供一个 TCP 转发器，将 TLS 终止的 TCP 数据包转发到本地 TCP 服务器，如 Caddy 或其他基于 TCP 的协议，如 SSH 或 RDP。默认情况下，TCP 转发器转发原始数据包。

- `--tcp=<port>` 在指定端口设置原始 TCP 转发器。对于 Funnel，您必须使用允许的端口之一：`443`、`8443` 或 `10000`。

- `--tls-terminated-tcp=<port>` 在指定端口设置 TLS 终止的 TCP 转发器。对于 Funnel，您必须使用允许的端口之一：`443`、`8443` 或 `10000`。

## 使用有效证书

```shell
tailscale funnel <https:target>
```

如果您有有效证书，请在 `<target>` 参数中使用 `https`。

示例：`tailscale funnel https://localhost:8443`

## 忽略无效和自签名证书检查

```shell
tailscale funnel <https+insecure:target>
```

如果您使用自签名或其他无效证书运行本地 HTTPS Web 服务器，您可以为 `tailscale funnel` 命令指定 `https+insecure` 作为特殊的伪协议。

示例：`tailscale funnel https+insecure://localhost:8443`

## 获取状态

```shell
tailscale funnel status [--json]
```

要获取服务器的状态，您可以使用 `status` 子命令。这将列出当前在您的节点上运行的所有服务器。

- `--json` 如果您希望以 JSON 格式获取状态，可以提供 `--json` 参数。

示例：`tailscale funnel status --json`

## 重置 Tailscale Funnel

```shell
tailscale funnel reset
```

要清除当前的 `tailscale funnel` 配置，请使用 `reset` 子命令。

## 关闭 Tailscale Funnel

- `[off]` 要关闭 `tailscale funnel` 命令，您可以在用于打开它的命令末尾添加 `off`。这将从活动服务器列表中删除服务器。在 `off` 命令中，`<target>` 参数是可选的，但所有原始标志都是必需的。

如果此命令打开了服务器：

```shell
tailscale funnel --https=443 /home/alice/blog/index.html
```

您可以通过运行以下命令将其关闭：

```shell
tailscale funnel --https=443 /home/alice/blog/index.html off
```

您可以省略 `<target>` 参数，因此这两个命令是等效的：

```shell
tailscale funnel --https=443 --set-path=/foo /home/alice/blog/index.html off
tailscale funnel --https=443 --set-path=/foo off
```

## 重启和重新启动的影响

如果您使用 [`-bg`](#funnel-command-flags) 标志运行 `tailscale funnel` 命令，它将在后台持续运行，直到您[将其关闭](#turn-tailscale-funnel-off)。当您重新启动设备或使用 [`tailscale down`](https://tailscale.com/kb/1080/cli#down) 和 [`tailscale up`](https://tailscale.com/kb/1080/cli#up) 从命令行重新启动 Tailscale 时，Funnel 将自动恢复共享。

如果您不使用 `-bg` 标志运行 `tailscale funnel` 命令，然后重新启动设备或从命令行重新启动 Tailscale，您必须手动重新启动 Funnel 以恢复共享。

---

# [tailscale lock command](https://tailscale.com/kb/1243/tailscale-lock)

`tailscale lock` 管理您的 tailnet 的 [Tailnet Lock](https://tailscale.com/kb/1226/tailnet-lock)。

```shell
tailscale lock <subcommand> [flags] <args>
```

子命令：

- [`init`](#lock-init) 初始化 Tailnet Lock。
- [`status`](#lock-status) 输出 Tailnet Lock 的状态。
- [`add`](#lock-add) 向 Tailnet Lock 添加一个或多个受信任的签名密钥。
- [`remove`](#lock-remove) 从 Tailnet Lock 中移除一个或多个受信任的签名密钥。
- [`sign`](#lock-sign) 对节点密钥进行签名，并将签名传输到协调服务器。
- [`disable`](#lock-disable) 使用禁用密钥关闭 tailnet 的 Tailnet Lock。
- [`log`](#lock-log) 列出应用于 Tailnet Lock 的更改。
- [`local-disable`](#lock-local-disable) 仅为此节点禁用 Tailnet Lock。
- [`revoke-keys`](#lock-revoke-keys) 追溯撤销一个或多个 Tailnet Lock 密钥。

不带子命令和参数运行 `Tailnet Lock` 等同于运行 [`tailscale lock status`](#lock-status)。

示例：

```shell
tailscale lock
```

示例输出：

```markup
Tailnet Lock is ENABLED.

This node is accessible under Tailnet Lock.

This node's tailnet-lock key: tlpub:1234abcdef

Trusted signing keys:
	tlpub:1234abcdef	(us)
```

## lock init

为整个 tailnet 初始化 [Tailnet Lock](https://tailscale.com/kb/1226/tailnet-lock)。

```shell
tailscale lock init [flags] <tlpub:trusted-key1 tlpub:trusted-key2 ...>
```

可用标志：

- `--confirm=false` 是否提示确认。如果为 `true`，则不会提示确认。
- `--gen-disablement-for-support` 生成一个额外的禁用密钥并将其传输给 Tailscale 支持。然后 Tailscale 支持可以使用它来禁用 Tailnet Lock。请注意，如果 Tailscale 支持禁用了 Tailnet Lock，它将保持禁用状态，Tailscale 支持无法重新启用它，因此这将被视为紧急恢复机制，而不是临时禁用 Tailnet Lock。
- `--gen-disablements <N>` 要生成的禁用密钥数量。如果未指定，默认为一个禁用密钥，这是初始化 Tailnet Lock 所需的最小数量。

指定的 Tailnet Lock 密钥是初始受信任的密钥，用于对节点进行签名或对您的 Tailnet Lock 配置进行进一步更改。这些是 Tailnet Lock 公钥。您可以通过在该节点上运行 `tailscale lock` 然后复制该节点的 Tailnet Lock 密钥来识别您希望信任的节点的 Tailnet Lock 密钥。

您必须将运行 `tailscale lock init` 的节点的 Tailnet Lock 密钥指定为受信任的 Tailnet Lock 密钥之一。附加密钥列表必须用空格分隔。

> **注意**：禁用密钥仅在您初始化 Tailnet Lock 时显示。请记下它们并将其安全地保存在安全的地方。

示例：

```shell
tailscale lock init --gen-disablements=3 --gen-disablement-for-support \
  --confirm tlpub:1234abcdef
```

示例输出：

```markup
You are initializing Tailnet Lock with the following trusted signing keys:
 - tlpub:1234abcdef (25519 key)

3 disablement secrets have been generated and are printed below. Take note of them now, they WILL NOT be shown again.
	disablement-secret:ABC1234
	disablement-secret:DEF5678
	disablement-secret:GHI9012
A disablement secret for Tailscale support has been generated and will be transmitted to Tailscale upon initialization.
Initialization complete.
```

禁用密钥是禁用您的 Tailnet Lock 所需的长密码。有关更多信息，请参阅 [`tailscale lock disable`](#lock-disable) 命令。

禁用密钥的数量将是您为 `--gen-disablements` 指定的值。如果您设置了 `--gen-disablement-for-support`，您将收到一条关于为 Tailscale 支持生成禁用密钥的消息。

## lock status

输出 Tailnet Lock 的状态。该命令显示 Tailnet Lock 是否已启用、节点的 Tailnet Lock 公钥的值，以及哪些节点被 Tailnet Lock 锁定且无法连接到其他节点。

```shell
tailscale lock status [flags]
```

可用标志：

- `--json` 返回机器可读的 JSON 响应。

示例：

```shell
tailscale lock status
```

示例输出：

```markup
Tailnet Lock is ENABLED.

This node is accessible under Tailnet Lock.

This node's tailnet-lock key: tlpub:1234abcdef

Trusted signing keys:
	tlpub:1234abcdef	(us)
```

如果您运行 `tailscale lock status` 的节点没有可访问的密钥，输出将如下所示：

```markup
This node is LOCKED OUT by tailnet-lock, and action is required to establish connectivity.
Run the following command on a node with a trusted key:
	tailscale lock sign nodekey:abcdef12 tlpub:11223344
```

如果您的一个对等节点被锁定在您的 tailnet 之外，在受信任签名密钥列表之后，输出将如下所示：

```markup
 The following nodes are locked out by Tailnet Lock and cannot connect to other nodes:
	bob.yak-bebop.ts.net.	100.111.222.33, fd7a:115c:a1e0:aabb:ccdd:eeff:0123:4567	n12345CNTRL
```

## lock add

向 Tailnet Lock 添加一个或多个受信任的签名密钥。

此命令需要从具有受信任 Tailnet Lock 密钥的节点运行。

```shell
tailscale lock add <tlpub:trusted-key1 tlpub:trusted-key2 ...>
```

指定的 Tailnet Lock 密钥是 Tailnet Lock 公钥。您可以通过在该节点上运行 `tailscale lock` 然后复制该节点的 Tailnet Lock 密钥来识别 Tailnet Lock 密钥。

附加密钥列表必须用空格分隔。

## lock remove

从 Tailnet Lock 中移除一个或多个受信任的签名密钥。

此命令需要从具有受信任 Tailnet Lock 密钥的节点运行。

```shell
tailscale lock remove [flags] <tlpub:trusted-key1 tlpub:trusted-key2 ...>
```

可用标志：

- `--re-sign` 重新签署因移除受信任签名密钥而失效的签名。默认为 true。

指定的 Tailnet Lock 密钥是 Tailnet Lock 公钥。您可以通过在该节点上运行 `tailscale lock` 然后复制该节点的 Tailnet Lock 密钥来识别 Tailnet Lock 密钥。

附加密钥列表必须用空格分隔。

## lock sign

执行签名操作。`tailscale lock sign` 有两种签名模式：

- 使用当前节点（运行命令的节点）上的 Tailnet Lock 密钥对节点密钥进行签名，并将签名传输到协调服务器。
- 对 [预批准的 auth 密钥](https://tailscale.com/kb/1085/auth-keys) 进行签名，以可用于在 [Tailnet Lock](https://tailscale.com/kb/1226/tailnet-lock) 下启动节点的形式打印。具体来说，它 [对 auth 密钥进行签名](https://tailscale.com/kb/1226/tailnet-lock#add-a-node-using-a-pre-signed-auth-key)，以便它可以验证新节点，而无需在将新节点添加到 tailnet 之前对其进行签名。每个签名的 auth 密钥，也称为包装的 auth 密钥，都嵌入了一个签名密钥，可以对一个新节点或多个节点进行签名，直到它被 [移除](#lock-remove) 为止。

对节点密钥进行签名对于为被 Tailnet Lock 锁定的节点建立连接是必需的。

如果任何密钥参数以 `file:` 开头，则从参数后缀中指定的路径的文件中检索密钥。

此命令需要从具有受信任 Tailnet Lock 密钥的节点运行。

```shell
tailscale lock sign <node-key> [<rotation-key>]
```

或

```shell
tailscale lock sign <auth-key>
```

示例：

此示例演示了对节点密钥进行签名，可选择使用节点的 Tailnet Lock 密钥（`tlpub:trusted-key2`）来支持密钥轮换。

```shell
tailscale lock sign nodekey:1abddef1 tlpub:trusted-key2
```

此示例显示了对 auth 密钥进行签名。在此示例中，`$AUTH_KEY` 是一个环境变量，设置为 [预批准](https://tailscale.com/kb/1085/auth-keys#types-of-auth-keys) 的 auth 密钥，您 [已经生成](https://tailscale.com/kb/1085/auth-keys#generate-an-auth-key)。

```shell
tailscale lock sign $AUTH_KEY
```

成功运行该命令的输出是一个签名的预批准 auth 密钥，然后您可以使用它来 [预批准设备](https://tailscale.com/kb/1099/device-approval#pre-approve-devices-with-an-auth-key) 在您的 tailnet 中。

> **警告**：当您创建签名的 auth 密钥时，会为其创建一个新的受信任签名密钥，并将其添加到 [tailnet 密钥授权机构](https://tailscale.com/kb/1226/tailnet-lock#tailnet-key-authority)。签名密钥的私钥被编码在签名的 auth 密钥中。签名的 auth 密钥等同于 tailnet 中签名节点上的私钥，如果泄露，将对您的 tailnet 构成风险。即使 auth 密钥是单次使用的，签名密钥也会保持受信任状态，直到从 tailnet 密钥授权机构中移除。
>
> 出于安全最佳实践，我们不建议使用签名的 auth 密钥。

## lock disable

使用指定的禁用密钥为整个 tailnet 禁用 Tailnet Lock。

```shell
tailscale lock disable <disablement-secret>
```

禁用 Tailnet Lock 是一个与安全相关的操作——如果禁用过程缺乏授权检查，受损的控制平面可能会轻易地禁用 Tailnet Lock（及其所有保护）来攻击 tailnet。为避免这种情况，需要使用禁用密钥来全局禁用 Tailnet Lock。

禁用密钥是在启用 Tailnet Lock 的过程中生成的长密码，当您运行 [`tailscale lock init`](#lock-init) 时。每个禁用密钥的密钥派生函数（KDF）派生值由每个节点的 tailnet 密钥授权机构存储（因此 tailnet 中的每个节点都知道），但密钥本身在使用前保持机密。

当使用禁用密钥时，该密钥会分发到 tailnet 中的所有节点。然后，每个节点可以通过计算密钥的 KDF 值并将其与其 tailnet 密钥授权机构（TKA）中存储的 KDF 值进行比较来验证禁用操作的真实性。如果匹配，则节点可以确保禁用是真实的，并在本地禁用 Tailnet Lock。

一旦使用了指定的 `disablement-secret` 密钥，它就会被分发到 tailnet 中的所有节点，应被视为公开的。

如果重新启用 Tailnet Lock，将生成新的禁用密钥。

示例：

```shell
tailscale lock disable disablement-secret:ABC1234
```

## lock disablement-kdf

从禁用密钥计算禁用值。此命令仅供高级用户使用。

```shell
tailscale lock disablement-kdf <hex-encoded-disablement-secret>
```

## lock log

列出应用于 Tailnet Lock 的更改。

```shell
tailscale lock log [flags]
```

可用标志：

- `--json` 返回机器可读的 JSON 响应。
- `--limit` 要列出的最大更改数量。默认为 50。

示例：

```shell
tailscale lock log
```

示例输出：

```markup
update 17310b8e655867d3973a72cd20bc7c21f81f7687b4e7911c285f2eb16df5df36 (checkpoint)
Disablement values:
 - 1234abcd
 - 9876aaaa
 - c1d2e3f4
 - 8f6e4d2c
Keys:
  Type: 25519
  KeyID: 1234abcdef
  Votes: 1
```

## lock local-disable

仅为此节点禁用 Tailnet Lock。

```shell
tailscale lock local-disable
```

此命令仅禁用当前节点（运行命令的节点）的 Tailnet Lock。如果仅为此节点禁用 Tailnet Lock，该节点现在将接受来自被锁定节点的流量。这并不意味着该节点可以发送或接收来自 tailnet 中已签名其他节点的流量。

如果您遇到整个 tailnet 的 Tailnet Lock 重大问题，并且无法使用 [`tailscale lock disable`](#lock-disable) 禁用它（例如，如果您找不到您的禁用密钥），您可以在每个节点上运行 `tailscale lock local-disable`，以使您的 tailnet 实际上忽略 Tailnet Lock。

## lock revoke-keys

追溯撤销指定的 Tailnet Lock 密钥。

此命令需要从具有受信任 Tailnet Lock 密钥的节点运行。

```shell
tailscale lock revoke-keys <tlpub:key1 tlpub:key2 ...> [flags]
```

可用标志：

- `--cosign=false` 使用此设备上的 Tailnet Lock 密钥和来自另一个具有受信任 Tailnet Lock 密钥且已运行 `tailscale lock revoke-keys` 的设备的提供的恢复命令，继续密钥撤销。
- `--finish=false` 通过传输撤销来完成恢复过程。
- `--fork-from <hash>`（仅限高级用户）要从中重写 tailnet 密钥授权机构状态的父 [授权更新消息](https://tailscale.com/kb/1230/tailnet-lock-whitepaper#authority-update-messages-aums)（AUM）的哈希值。

指定的 Tailnet Lock 密钥是 Tailnet Lock 公钥。您可以通过在该节点上运行 `tailscale lock` 然后复制该节点的 Tailnet Lock 密钥来识别 Tailnet Lock 密钥。

附加密钥列表必须用空格分隔。

> **注意**：如果您想移除未受损的密钥，请改用 [`tailscale lock remove`](#lock-remove) 命令。

撤销是一个多步骤过程，需要多个签名节点共同签署撤销。每个步骤都使用 `tailscale lock revoke-keys` 命令。

1. 在没有受损密钥的签名节点上打开终端。
2. 运行以下命令，其中 `<tlpub:compromised-key1 tlpub:compromised-key2>` 是您要撤销的密钥的空格分隔列表：

   ```shell
   tailscale lock revoke-keys tlpub:compromised-key1 tlpub:compromised-key2
   ```

   此命令的输出包含一个 `tailscale lock revoke-keys --cosign` 命令，您将在下一步中使用。

3. 在另一个受信任的签名节点上，运行 `tailscale lock revoke-keys --cosign` 命令。此命令的输出包含一个新的 `tailscale lock revoke-keys --cosign` 命令。重复此过程，始终使用每个 `--cosign` 命令的新输出，直到您使用 `--cosign` 的次数超过撤销密钥的数量。例如，如果您撤销了 3 个密钥，则需要运行 `tailscale lock revoke-keys --cosign` 命令 4 次。

4. 通过运行从最后一次使用 `--cosign` 输出的命令来完成过程，**但**将 `--cosign` 替换为 `--finish`：

   ```shell
   tailscale lock revoke-keys --finish <hex-data>
   ```

默认情况下，Tailscale 将确定在 Tailnet Lock 日志中分叉的适当点。如果同意应撤销密钥的签名节点多于不同意的签名节点，则 Tailscale 确定的分叉中仍受信任的密钥将用于代替已撤销的密钥。

如果大多数签名节点受损，您可以 [禁用](https://tailscale.com/kb/1226/tailnet-lock#disable-tailnet-lock) 然后 [重新启用](https://tailscale.com/kb/1226/tailnet-lock#enable-tailnet-lock) Tailnet Lock 本身。

---

# [tailscale serve command](https://tailscale.com/kb/1242/tailscale-serve)

> **注意**：Tailscale Funnel 和 Tailscale Serve 的 CLI 命令在 Tailscale 客户端 1.52 版本中已更改。如果您在之前的版本中使用过 Funnel 或 Serve，建议查看 CLI 文档。

`tailscale serve` 让您可以在 Tailscale 网络（称为 tailnet）内安全地共享本地服务。

```shell
tailscale serve [flags] <target>
```

您也可以选择使用 [Tailscale Funnel](https://tailscale.com/kb/1223/funnel) 配合 [`tailscale funnel`](https://tailscale.com/kb/1311/tailscale-funnel) 命令将您的服务公开暴露给整个互联网。

子命令：

- [`status`](#get-the-status) 获取状态
- [`reset`](#reset-tailscale-serve) 重置配置
- [`drain`](#drain) 排空 [服务](https://tailscale.com/kb/1552/tailscale-services)
- [`advertise`](#advertise) 宣告 [服务](https://tailscale.com/kb/1552/tailscale-services)
- [`get-config`](#get-service-config) 获取 [服务](https://tailscale.com/kb/1552/tailscale-services) 配置
- [`set-config`](#set-service-config) 设置 [服务](https://tailscale.com/kb/1552/tailscale-services) 配置

有关各种用例和示例，请参阅 [Tailscale Serve 示例](https://tailscale.com/kb/1313/serve-examples)。

## Serve 命令标志

可用标志：

- `--accept-app-caps=<capability-1,capability-2,...>` 要转发给服务器的 [应用能力](https://tailscale.com/kb/1537/grants-app-capabilities)（使用逗号分隔列表指定多个能力）。
- `--bg` 确定命令是否应作为后台进程运行。
- `--http=<port>` 在指定端口暴露 HTTP 服务器。
- `--https=<port>` 在指定端口暴露 HTTPS 服务器（默认）。
- `--proxy-protocol=<version>` 用于 TCP 转发的 PROXY 协议版本（1 或 2）。
- `--service=<virtual-ip>` 为具有不同虚拟 IP 的 [Tailscale 服务](https://tailscale.com/kb/1552/tailscale-services) 提供服务，而不是设备的 IP 地址。
- `--set-path=<path>` 将指定路径附加到访问底层服务的基础 URL。
- `--tcp=<port>` 在指定端口暴露 TCP 转发器以转发 TCP 数据包。
- `--tls-terminated-tcp=<port>` 在指定端口暴露 TLS 终止的 TCP 转发器以转发 TCP 数据包。
- `--tun` 将 [第 3 层服务](https://tailscale.com/kb/1552/tailscale-services#layer-3-endpoints-network-layer) 配置为将所有流量转发到本地机器（默认为 false）；仅支持服务。
- `--yes` 无需交互式提示即可更新。

`tailscale serve` 命令接受一个目标，该目标可以是文件、目录、文本，或最常见的是本地设备上运行的服务的位置。您可以将本地服务的位置写为端口号（例如 `3000`）、部分 URL（例如 `localhost:3000`）或包含路径的完整 URL（例如 `tcp://localhost:3000/foo`、`https+insecure://localhost:3000/foo`）。

## 使用 HTTPS 和 HTTP 服务器

```shell
tailscale serve --https=<port> <target> [off]
tailscale serve --http=<port> <target> [off]
```

`serve` 提供 HTTPS 和 HTTP 服务器，有几种模式：反向代理、文件服务器和静态文本服务器。HTTPS 流量使用自动配置的 TLS 证书。默认情况下，设备的 Tailscale 守护进程终止 HTTPS 连接。

- `--https=<port>` 或 `http=<port>` 指定要监听的端口

- `--set-path` 是一个斜杠分隔的 URL 路径。根级挂载点将是 `/`，并且将通过向 `https://my-node.example.ts.net/` 发出请求来匹配。有关这些路径模式如何匹配的更多信息，请参阅 Go [ServeMux](https://pkg.go.dev/net/http#ServeMux) 文档。我们的挂载点行为类似。

- `<target>` Serve 提供 4 个内容服务选项：HTTP 反向代理、文件、目录和静态文本。反向代理允许您将请求转发到本地 HTTP Web 服务器。提供本地文件路径可以提供服务文件或文件目录的能力。静态文本服务主要用于调试目的，并提供静态响应。

  - **反向代理**

    要作为本地后端的反向代理，请提供 `<target>` 参数的位置。您可以将本地服务的位置写为端口号（例如 `3000`）、部分 URL（例如 `localhost:3000`）或包含路径的完整 URL（例如 `tcp://localhost:3000/foo`、`https+insecure://localhost:3000/foo`）。请注意，只有 `http://127.0.0.1` 支持代理。

    示例：`tailscale serve localhost:3000`

    或者，通过 HTTP 提供服务：

    示例：`tailscale serve --http=80 localhost:3000`

    HTTP 服务器可以使用简短的 MagicDNS 名称访问，如 `http://my-node`

  - **文件服务器**

    提供您希望服务的文件或文件目录的完整绝对路径。如果您指定目录，这将呈现一个包含指向文件和子目录链接的目录列表。

    示例：`tailscale serve /home/alice/blog/index.html`

    由于 macOS 应用沙盒限制，此选项仅在使用 Tailscale 的[开源版本](https://tailscale.com/kb/1065/macos-variants)时有效。如果您通过 Mac App Store 或作为独立版本系统扩展在 macOS 上安装了 Tailscale，您可以使用 Serve 共享端口，但不能共享文件或目录。

  - **静态文本服务器**

    将 `text:<value>` 指定为 `<target>` 会配置一个静态纯文本服务器。

    示例：`tailscale serve text:"Hello, world!"`

## 使用 PROXY 协议

```shell
tailscale serve --proxy-protocol=<version> <target>
```

> **注意**：对于大多数情况，用户可能会使用版本 `2`。

[PROXY 协议](https://www.haproxy.com/blog/use-the-proxy-protocol-to-preserve-a-clients-ip-address)是一种最小的网络协议，用于保留有关代理连接的信息（通常是源 IP 地址），通过代理或负载均衡器传递到后端目标。这使您使用 Serve 公开的服务能够确定连接客户端的原始 IP 地址和端口。

例如：

```shell
$ tailscale serve --proxy-protocol=2 --tls-terminated-tcp=443 tcp://127.0.0.1:9899
Available within your tailnet:

|-- tcp://serve-test.example.ts.net:443 (TLS terminated, PROXY protocol v2)
|-- tcp://100.101.102.103:443
|-- tcp://[fd7a:115c:a1e0::1111:2222]:443
|---> tcp://127.0.0.1:9899

Press Ctrl+C to exit.
```

后端（运行在 `localhost:9899`）然后通过 PROXY 协议获取原始源 IP 和端口。

## 使用 TCP 转发器

```shell
tailscale serve --tcp=<port> tcp://localhost:<local-port> [off]
tailscale serve --tls-terminated-tcp=<port> tcp://localhost:<local-port> [off]
```

`serve` 命令提供一个 TCP 转发器，您可以使用它将原始 TCP 数据包和 TLS 终止的 TCP 数据包转发到本地 TCP 服务器，如 Caddy 或其他基于 TCP 的协议，如 SSH 或 RDP。默认情况下，TCP 转发器转发原始数据包。

- `--tcp=<port>` 在指定端口设置原始 TCP 转发器。您可以使用任何有效的端口号。

- `--tls-terminated-tcp=<port>` 在指定端口设置 TLS 终止的 TCP 转发器。您可以使用任何有效的端口号。

- `tcp://localhost:<local-port>` 指定要转发数据包的本地端口。

## 使用有效证书

```shell
tailscale serve <https:target>
```

如果您有有效证书，请在 `<target>` 参数中使用 `https`。

示例：`tailscale serve https://localhost:8443`

## 忽略无效和自签名证书检查

```shell
tailscale serve <https+insecure:target>
```

如果您使用自签名或其他无效证书运行本地 HTTPS Web 服务器，您可以为 `tailscale serve` 命令指定 `https+insecure` 作为特殊的伪协议。

示例：`tailscale serve https+insecure://localhost:8443`

## 获取状态

```shell
tailscale serve status [--json]
```

要获取服务器的状态，您可以使用 `status` 子命令。这将列出当前在您的设备上运行的所有服务器。

- `--json` 如果您希望以 JSON 格式获取状态，可以提供 `--json` 参数。

  示例：`tailscale serve status --json`

## 重置 Tailscale Serve

```shell
tailscale serve reset
```

要清除当前的 `tailscale serve` 配置，请使用 `reset` 子命令。

## 禁用 Tailscale Serve

- `[off]` 要关闭 `tailscale serve` 命令，您可以在用于打开它的命令末尾添加 `off`。这将从活动服务器列表中删除服务器。在 `off` 命令中，`<target>` 参数是可选的，但所有原始标志都是必需的。

如果此命令打开了服务器：

```shell
tailscale serve --https=443 /home/alice/blog/index.html
```

您可以通过运行以下命令将其关闭：

```shell
tailscale serve --https=443 /home/alice/blog/index.html off
```

您可以省略 `<target>` 参数，因此这两个命令是等效的：

```shell
tailscale serve --https=443 --set-path=/foo /home/alice/blog/index.html off
tailscale serve --https=443 --set-path=/foo off
```

## 获取服务配置

```shell
tailscale serve get-config <file> [flags]
```

获取此节点当前托管的[服务](https://tailscale.com/kb/1552/tailscale-services)的配置，格式可以稍后提供给 `set-config`。这可用于声明服务主机的配置。

可用标志：

- `--all` 从所有服务读取配置。
- `--service=<name>` 从特定服务读取配置。

## 设置服务配置

```shell
tailscale serve set-config <file> [flags]
```

读取提供的[配置文件](https://tailscale.com/kb/1589/tailscale-services-configuration-file)，并使用它为单个[服务](https://tailscale.com/kb/1552/tailscale-services)或此节点托管的所有服务声明配置。

- `--all` 将配置应用于所有服务。
- `--service=<name>` 将配置应用于特定服务。

## 排空

```shell
tailscale serve drain <service>
```

从当前节点排空[服务](https://tailscale.com/kb/1552/tailscale-services)。

使用此命令可以优雅地从当前节点移除服务，而不会中断现有连接。不会接受新连接，但现有连接将继续工作直到关闭。

`<service>` 应该是服务名称。例如：`svc:my-service`。

## 宣告

```shell
tailscale serve advertise <service>
```

将此节点宣告为 tailnet 的[服务](https://tailscale.com/kb/1552/tailscale-services)主机。

此命令可用于在[排空](#drain)后将服务主机重新上线。如果您使用 `tailscale serve` 初始化服务，则不需要此操作。

`<service>` 应该是服务名称。例如：`svc:my-service`。

可用标志：

- `--service=<name>` 将配置应用于特定服务。

## 重启和重新启动的影响

如果您使用 [`-bg`](#serve-command-flags) 标志运行 `tailscale serve` 命令，它将在后台持续运行，直到您[禁用](#disable-tailscale-serve)它。当您重新启动设备或使用 [`tailscale down`](https://tailscale.com/kb/1080/cli#down) 和 [`tailscale up`](https://tailscale.com/kb/1080/cli#up) 从命令行重新启动 Tailscale 时，Serve 将自动恢复共享。

如果您不使用 `-bg` 标志运行 `tailscale serve` 命令，然后重新启动设备或从命令行重新启动 Tailscale，您必须手动重新启动 Serve 以恢复共享。

> **注意**：当您将 `tailscale serve` 命令与 [Tailscale 服务](https://tailscale.com/kb/1552/tailscale-services)一起使用时，它默认在后台运行。

---

# [tailscale up command](https://tailscale.com/kb/1241/tailscale-up)

`tailscale up` 将您的设备连接到 Tailscale，并在需要时进行身份验证。

```shell
tailscale up [flags]
```

不带任何标志运行 `tailscale up` 即可连接到 Tailscale。

您可以指定标志来配置 Tailscale 的行为。标志不会在运行之间持久化；每次都必须指定所有标志。

要清除先前设置的标志（如标签和路由），请使用空参数传递该标志：

```shell
# 使用 `tag:server` 连接
tailscale up --advertise-tags=tag:server

# 连接并清除所有标签
tailscale up --advertise-tags=
```

在 Tailscale v1.8 或更高版本中，如果您忘记指定之前添加的标志，CLI 会发出警告并提供包含所有现有标志的可复制命令。

可用标志：

- `--accept-dns` 接受来自管理控制台的 [DNS 配置](https://tailscale.com/kb/1054/dns)。默认为接受 DNS 设置。
- `--accept-risk=<risk>` 接受风险并跳过风险类型的确认。可以是 `lose-ssh` 或 `all`，或空字符串表示不接受风险。
- `--accept-routes` 接受其他节点通告的 [子网路由](https://tailscale.com/kb/1019/subnets)。默认值取决于主机操作系统。对于某些平台——Windows、iOS、Android、macOS App Store 版本和 macOS 独立版本——默认是接受路由。所有其他平台默认不接受路由。
- `--advertise-connector` 将此节点通告为 [应用连接器](https://tailscale.com/kb/1281/app-connectors)。
- `--advertise-exit-node` 提供作为 Tailscale 网络出站互联网流量的 [出口节点](https://tailscale.com/kb/1103/exit-nodes)。默认为不提供作为出口节点。
- `--advertise-routes=<ip>` 向您的整个 Tailscale 网络公开物理 [子网路由](https://tailscale.com/kb/1019/subnets)。
- `--advertise-tags=<tags>` 为此设备提供标记权限。您必须 [在 `"TagOwners"` 中列出](https://tailscale.com/kb/1337/policy-syntax#tag-owners) 才能应用标签。
- `--auth-key=<key>` 提供 [身份验证密钥](https://tailscale.com/kb/1085/auth-keys) 以自动将节点验证为您的用户帐户。
- `--client-id` 用于通过 [工作负载身份联合](https://tailscale.com/kb/1581/workload-identity-federation) 生成 [身份验证密钥](https://tailscale.com/kb/1085/auth-keys) 的客户端 ID。
- `--client-secret` 用于生成 [身份验证密钥](https://tailscale.com/kb/1085/auth-keys) 的 [OAuth 客户端](https://tailscale.com/kb/1215/oauth-clients) 密钥；如果以 `file:` 开头，则是包含密钥的文件路径。
- `--exit-node=<ip|name>` 提供要用作出口节点的 [Tailscale IP](https://tailscale.com/kb/1033/ip-and-dns-addresses) 或 [机器名称](https://tailscale.com/kb/1098/machine-names)。您还可以使用 `--exit-node=auto:any` 跟踪建议的出口节点，并在可用出口节点或网络条件变化时自动切换。要禁用出口节点的使用，请使用空参数传递标志 `--exit-node=`。
- `--exit-node-allow-lan-access` 允许客户端节点在连接到出口节点时访问其自己的 LAN。默认为连接到出口节点时不允许访问。
- `--force-reauth` 强制重新身份验证。
- `--hostname=<name>` 提供用于设备的替代主机名，而不是操作系统提供的主机名。请注意，这将更改 [MagicDNS](https://tailscale.com/kb/1081/magicdns) 中使用的机器名称。
- `--id-token` 来自身份提供者的 ID 令牌，用于与控制服务器交换以进行 [工作负载身份联合](https://tailscale.com/kb/1581/workload-identity-federation)；如果以 `file:` 开头，则是包含令牌的文件路径。
- `--audience` 从身份提供者请求 ID 令牌时使用的受众，用于通过 [工作负载身份联合](https://tailscale.com/kb/1581/workload-identity-federation) 生成的身份验证密钥。
- `--json` 以 JSON 格式输出。格式可能会更改。
- `--login-server=<url>` 提供控制服务器的基础 URL，而不是 `https://controlplane.tailscale.com`。如果您使用 [Headscale](https://tailscale.com/blog/opensource#the-open-source-coordination-server) 作为控制服务器，请使用您的 Headscale 实例的 URL。
- `--netfilter-mode`（仅限 Linux）用于控制自动防火墙配置程度的高级功能。值可以是 `off`、`nodivert` 或 `on`。默认为 `on`，但 Synology 默认为 `off`。将此标志设置为 `off` 会禁用所有 `netfilter` 管理。设置为 `nodivert` 会创建和管理 Tailscale 子链，但将这些链的调用留给管理员。设置为 `on` 意味着完全管理 Tailscale 的规则。请注意，如果您将 `--netfilter-mode` 设置为 `off` 或 `nodivert`，您有责任为 Tailscale 流量安全地配置防火墙。我们建议将 `--netfilter-mode=on` 安装的规则作为起点。有关更多信息，请参阅 [netfilter 模式](https://tailscale.com/kb/1593/netfilter-modes)。
- `--operator=<user>` 提供除 `root` 之外的 Unix 用户名来操作 `tailscaled`。
- `--qr` 为 Web 登录 URL 生成二维码。默认为不显示二维码。
- `--qr-format=<format>` 二维码格式：`small` 或 `large`。默认为 `small`。
- `--reset` 将未指定的设置重置为默认值。
- `--shields-up` [阻止来自 Tailscale 网络上其他设备的传入连接](https://tailscale.com/kb/1072/client-preferences)。适用于仅建立出站连接的个人设备。
- `--snat-subnet-routes`（仅限 Linux）对使用 `--advertise-routes` 通告的本地路由进行源 NAT 流量。默认为对通告的路由进行 NAT 流量源。设置为 false 以禁用子网路由伪装。
- `--stateful-filtering`（仅限 Linux）为子网路由器和出口节点启用有状态过滤。启用后，目标 IP 为其他节点的入站数据包将被丢弃，除非它们是该节点跟踪的出站连接的一部分。默认为禁用。
- `--ssh` 运行 [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh) 服务器，根据 tailnet 管理员声明的 [访问策略](https://tailscale.com/kb/1018/acls) 或 [默认策略](https://tailscale.com/kb/1192/acl-samples#allow-all-default-acl)（如果未定义）允许访问。默认为 false。
- `--timeout=<duration>` 等待 Tailscale 服务初始化的最长时间。`duration` 可以是 [time.ParseDuration()](https://pkg.go.dev/time#ParseDuration) 可解析的任何值。默认为 `0s`，表示永远阻塞。
- `--unattended`（仅限 Windows）在 [无人值守模式](https://tailscale.com/kb/1088/run-unattended) 下运行，即使当前用户注销后 Tailscale 仍继续运行。

---

# [tailscaled daemon](https://tailscale.com/kb/1278/tailscaled)

在您的设备上运行的 Tailscale 软件分布在多个二进制文件和进程中。

## 平台差异

在大多数平台上，[CLI](https://tailscale.com/kb/1080/cli) 是一个名为 `tailscale`（或 `tailscale.exe`）的二进制文件，而执行所有网络处理的更高权限守护进程称为 `tailscaled`（或 `tailscaled.exe`）。注意最后的 `d` 代表"守护进程（daemon）"。使用 `tailscale` 命令可访问的大多数 CLI 命令要求守护进程在机器上运行。

在 macOS 上[有三种运行 Tailscale 的方式](https://tailscale.com/kb/1065/macos-variants)。只有第三种非 GUI 方式包含典型的 `tailscale` 与 `tailscaled` 分离。两种 GUI 变体将所有组件捆绑到一个二进制文件中，macOS 在不同上下文中加载：GUI、守护进程（App Store 版本命名为 `IPNExtension`，zip 文件下载版本命名为 `io.tailscale.ipn.macsys.network-extension`）和 CLI（与 GUI 相同的二进制文件，但从终端运行时会进入 CLI 模式）。两种 macOS GUI 变体的守护进程尽管名称不同，但实际上是相同的。但技术上它们不是 `tailscaled`（本主题的主题），尽管共享大部分相同的代码。值得注意的是，任何涉及更改 `tailscaled` 标志的 `tailscaled` 行为在 macOS GUI 变体上并不总是可用。

## tailscaled 在哪里运行？

在 Linux 和其他类 Unix 平台上，`tailscaled` 通常作为 systemd 服务运行，或者作为您的发行版或操作系统的 init 系统运行。

在 macOS 上，`tailscaled`（如上所述，不使用 GUI 构建时）作为 `launchd` 服务运行。

在 Windows 上，`tailscaled` 作为名为"Tailscale"的 Windows 服务运行。

## 停止和启动 tailscaled

您通常不需要手动停止和启动 `tailscaled` 进程。当您使用 CLI 命令 `tailscale down` 时，它应该进入空闲状态。但是，如果您正在调试某些内容或更改标志，则说明因平台而异。

在 systemd 上，您可以运行 `sudo systemctl $VERB tailscaled`，其中动词是 `stop`、`start`、`restart` 等之一。

在 Windows 上，您可以运行 `net stop Tailscale` 或 `net start Tailscale`，或使用 Windows 服务管理器。

## 从 tailscaled 获取日志

连接到守护进程并流式传输其日志的可移植方式是使用 CLI 并运行 `tailscale debug daemon-logs`。但是，它目前不支持获取任何追溯日志。

在 systemd 上，您可以使用 `journalctl -u tailscaled --since="1 hour ago"`。

在 Windows 上，请参阅 `C:\ProgramData\Tailscale\Logs`。

在 macOS 上，对于 GUI 构建，使用 `Console.app` 并搜索 `Tailscale` 或 `IPNExtension`。

## tailscaled 的标志

`tailscaled` 有许多标志（命令行参数）可以执行各种操作。有些不是稳定的接口，主要用于调试。一些更常用和稳定的标志包括：

- `--tun=NAME` 指定 TUN 设备名称，或 `userspace-networking` 作为不使用内核支持并在进程内完成所有操作的魔法值。
- `--port=N` 设置用于对等流量的 UDP 监听端口；0 表示自动选择。
- `--verbose=N`，其中 N 默认为 0。值 1 或更高表示越来越详细。
- `--debug=localhost:8080`，运行提供诸如 `/debug/pprof`、`/debug/metrics`、`/debug/ipn` 或 `/debug/magicsock` 等路径的调试 HTTP 服务器。可通过调试服务器访问的确切细节可能会随时间变化。
- `--no-logs-no-support` 禁用遥测并选择退出需要此类遥测进行调试的任何支持

要控制状态（包括首选项和密钥）的存储位置和方式，请使用：

- `--statedir=` 用于存储配置、密钥、Taildrop 文件和其他状态的磁盘目录。
- `--state=` 指向 `/path/to/file`、`kube:<secret-name>` 以使用 Kubernetes 密钥、`arn:aws:ssm:...` 将状态存储在 AWS SSM 中，或 `mem:` 不存储状态并注册为临时节点。默认情况下，如果未提供，状态存储在 `<statedir>/tailscaled.state` 中。
- `--encrypt-state` 可选地使用 Linux 上的本地 TPM 设备加密状态文件。

还有两个运行代理的标志：

- `--socks5-server=[host]:port`，运行 SOCK5 服务器，使您的 tailnet 可通过 SOCKS5 访问
- `--outbound-http-proxy-listen=[host]:port`，运行 HTTP 代理服务器，使您的 tailnet 可通过 HTTP 访问。

SOCK5 和 HTTP 代理可以具有相同的值，在这种情况下，只打开一个端口，但会根据客户端首先说的内容自动改变它所说的协议。

以下标志执行操作并退出：

- `--version` 打印版本信息并退出
- `--cleanup` 清理先前运行的系统状态

## 设置标志

设置 `tailscaled` 标志因平台而异。

在 Linux 上，您可以修改 `/etc/default/tailscaled` 中的 `FLAGS`，systemd 单元定义将包含这些标志。

## 环境变量

### Windows

您可以通过执行以下操作在 Windows 上设置一些环境变量：

- 在 `C:\ProgramData\Tailscale` 中创建 `tailscaled-env.txt` 文件。
- 在 `tailscaled-env.txt` 文件中，您可以设置 `PORT=N`（例如，更改默认 UDP 监听端口）。
- 保存文件并运行 `net stop Tailscale`、`net start Tailscale` 以应用更改。
