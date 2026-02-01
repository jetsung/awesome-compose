## 自定义 DERP 服务器

> 此文档从[**官方 DERP 文档**](https://tailscale.com/kb/1118/custom-derp-servers)提取并转为简体中文。

### 自定义 DERP 服务器目前处于测试阶段
自定义 DERP 服务器是由组织或个人（而非 Tailscale）为特定网络需求设置和管理的指定 [DERP 服务器](https://login.tailscale.com/kb/1232/derp-servers)。默认情况下，所有 Tailscale 网络（称为 tailnet）都使用 Tailscale 运营的 DERP 服务器。DERP 服务器主要在促进 Tailscale 网络（称为 [tailnet](https://login.tailscale.com/kb/1136/tailnet)）中的设备之间的连接方面发挥支持作用。但当 [直接连接](https://login.tailscale.com/kb/1257/connection-types) 不可行且 [对等中继](https://login.tailscale.com/kb/1591/peer-relays) 不可用时，它们也可作为备用机制。

在大多数情况下，无需运行自定义 DERP 服务器。DERP 服务器通常仅充当 tailnet 中设备之间的连接纽带（无法查看设备之间交换的数据）。

但是，在一些限制较多的网络环境中，设备更有可能使用 DERP 服务器，因为它们无法与其他设备建立直接连接。由于 DERP 中继连接比直接连接慢，你可能会遇到性能不佳的情况。如果你经常遇到 DERP 中继连接，并且想避免性能问题，通常最好 [找出无法建立直接连接的原因](https://login.tailscale.com/kb/1463/troubleshoot-connectivity) 或设置对等中继，而不是使用自定义 DERP 服务器。

#### Tailscale 对等中继
- 由于在你自己的网络或基础架构内运行，因此与 DERP 服务器相比，延迟更低，性能更好。
- 不会产生通过 DERP 服务器进行出口数据传输的额外成本（对于云环境）。
- 避免了维护自定义 DERP 服务器的开销和限制。

也就是说，在某些罕见情况下，运行自定义 DERP 服务器可能是有意义的。例如，你可能运行自定义 DERP 服务器以 [限制加密流量的路由，以符合公司政策](https://login.tailscale.com/kb/1167/release-stages#alpha)。

### 限制
在大多数情况下，无需运行自定义 DERP 服务器。但是，在某些罕见情况下，运行自定义 DERP 服务器是有意义的。要这样做，你必须构建、部署和更新 `cmd/derper` 二进制文件。

运行自定义 DERP 服务器是一项高级操作，需要你投入大量资源来设置和维护。此外，运行自定义 DERP 服务器有以下注意事项：
- 自定义 DERP 服务器不支持设备共享或其他跨 tailnet 功能。
- 与普通 DERP 服务器一样，自定义 DERP 服务器无法查看设备之间交换的数据，因为这些数据是加密的。因此，DERP 服务器对网络级调试没有帮助。
- 自定义 DERP 服务器无法从 Tailscale 控制平面的某些优化中受益。
- 自定义 DERP 服务器 [无法在防火墙或负载均衡器后面运行](https://login.tailscale.com/kb/1167/release-stages#direct-internet-access)。
- [Mullvad 出口节点](https://login.tailscale.com/kb/1258/mullvad-exit-nodes) 与自定义 DERP 服务器不兼容。
- 自定义 DERP 服务器不用于 [区域路由](https://login.tailscale.com/kb/1115/high-availability#regional-routing)。有关更新，请参阅 [问题 #12993](https://github.com/tailscale/tailscale/issues/12993)。

### 要求
自定义 DERP 服务器必须 [直接访问互联网](https://login.tailscale.com/kb/1167/release-stages#direct-internet-access)、[允许 ICMP 流量](https://login.tailscale.com/kb/1167/release-stages#icmp-traffic) 并 [为 HTTP、HTTPS 和 STUN 开放端口](https://login.tailscale.com/kb/1167/release-stages#required-ports)。

#### 直接互联网访问
DERP 服务器需要直接的互联网连接，并且不得位于 NAT 设备（如防火墙）或负载均衡器后面。存在此直接连接要求有两个关键原因：[设备识别](https://login.tailscale.com/kb/1167/release-stages#device-identification) 和 [协议兼容性](https://login.tailscale.com/kb/1167/release-stages#protocol-compatibility)。

##### 设备识别
DERP 服务器通过检查传入流量的源地址来识别 tailnet 设备。当流量通过 NAT 或负载均衡器时，此关键功能会失败，因为它们会修改原始源地址。

##### 协议兼容性
Tailscale 客户端使用 HTTP 升级协议来建立双向数据通道。大多数云负载均衡器系统不支持此协议，因此与 DERP 服务器操作不兼容。

运行自己的 DERP 服务器是一项高级操作，需要你投入大量资源来设置和维护。

#### 所需端口
DERP 服务器必须开放以下端口以运行 HTTP 服务器、HTTPS 服务器和 [STUN](https://en.wikipedia.org/wiki/STUN) 服务器。这三个服务的端口需要对互联网流量开放，以便你的 tailnet 中的用户可以从家中或咖啡店等地方访问它们。
| 服务器 | 端口 |
| --- | --- |
| HTTP | `80` |
| HTTPS | `443` |
| STUN | `3478` |

要为 HTTPS 和 STUN 使用其他端口号，请分别设置 [DERPNode.DERPPort](https://pkg.go.dev/tailscale.com/tailcfg#DERPNode.DERPPort) 或 [DERPNode.STUNPort](https://pkg.go.dev/tailscale.com/tailcfg#DERPNode.STUNPort)。你不能为 HTTP 使用自定义端口号。

#### ICMP 流量
DERP 服务器必须允许传入和传出的 ICMP（Internet 控制消息协议）流量。

Tailscale 运行 [DERP 中继服务器](https://login.tailscale.com/kb/1232/derp-servers) 来帮助连接你的节点。一般来说，你不需要自定义 Tailscale DERP 服务器。但是，这是可能的。

### 开始使用自定义 DERP 服务器
运行自己的 DERP 服务器是一项高级操作，需要你投入大量资源来设置和维护。在继续之前，请考虑 [要求](https://login.tailscale.com/kb/1167/release-stages#requirements) 和 [限制](https://login.tailscale.com/kb/1167/release-stages#limitations)。

要设置自定义 DERP 服务器，你需要：
1. 从源代码运行 DERP 服务器。
2. 将 DERP 服务器添加到你的 tailnet。

以下其他步骤是可选的：
1. 限制 tailnet 设备对自定义 DERP 服务器的访问。
2. 从你的 tailnet 中删除 Tailscale 的默认 DERP 服务器。

#### 从源代码运行 DERP 服务器
要运行自己的 DERP 服务器，你必须从源代码构建 DERP 服务器。使用 [最新版本的 Go](https://golang.org/doc/install)，运行：
```bash
go install tailscale.com/cmd/derper@latest
```
将最新的 DERP 服务器安装到 `$HOME/go/bin`。

在运行二进制文件之前，你需要一个指向你的服务器的域名。有了域名和二进制文件后，要在你的域名上启动 DERP 服务器，请运行：
```bash
sudo derper --hostname=example.com
```
这将在端口 443 上启动可通过你的域名访问的 DERP 服务器。然后，你可以按照步骤 2 中的说明将 DERP 服务器添加到你的 tailnet。

为了与 Tailscale 客户端更新保持兼容，你可能需要通过使用 `go install tailscale.com/cmd/derper@latest` 从源代码重新构建来定期更新 DERP 服务器。

#### 将自定义 DERP 服务器添加到你的 tailnet
如果你发现 Tailscale 在你所在的区域内没有提供 DERP 服务器，或者你因其他原因无法使用提供的 DERPs，你可以通过在你的 tailnet 的 [策略 JSON](https://login.tailscale.com/kb/1337/policy-syntax) 中指定它们来扩充或编辑 DERP 服务器集，方法是将 `derpMap` 键设置为 [DERPMap](https://pkg.go.dev/tailscale.com/tailcfg#DERPMap) 类型的值。

每个区域都有一个唯一的区域 ID。区域 ID 值 `900` 到 `999` 保留供自定义、用户指定的区域使用，Tailscale 不会使用。

例如，以下配置启用了一个主机名为 `example.com` 的自定义 DERP 服务器。有关更多选项，请参阅 [DERPRegion](https://pkg.go.dev/tailscale.com/tailcfg#DERPRegion) 和 [DERPNode](https://pkg.go.dev/tailscale.com/tailcfg#DERPNode) 的定义。
```json
{
  // ... tailnet 策略文件的其他部分
  "derpMap": {
    "Regions": {
      "900": {
        "RegionID": 900,
        "RegionCode": "myderp",
        "Nodes": [
          {
            "Name": "1",
            "RegionID": 900,
            "HostName": "example.com",
            // IPv4 和 IPv6 是可选的，但建议使用，以减少
            // 如果 DNS 不可用或出现问题时潜在的 DERP 连接问题。
            // 地址必须是可公开路由的，且不在私有 IP 范围内。
            "IPv4": "203.0.113.15",
            "IPv6": "2001:db8::1"
          }
        ]
      }
    }
  }
}
```
每个区域只能有一个 DERP 服务器。如果你需要 DERP 冗余，请使用多个区域，每个区域只有一个 DERP 服务器。

#### （可选）删除 Tailscale 的 DERP 服务器
出于各种原因，例如 [合规性](https://login.tailscale.com/kb/1167/release-stages#policy-compliance)，你可能不希望通过特定的 DERP 区域路由流量。你可以通过在 tailnet 策略文件中创建自定义 DERP 地图来删除你的 tailnet 中的设备可用的 DERP 区域。要排除一个区域，将其值设置为 `null`。设置为 `null` 时，你的 tailnet 中的设备无法连接到该区域的 DERP 服务器。

例如，以下 DERP 地图配置禁用了通过纽约 Tailscale DERP 区域（区域 ID 为 `1`）的流量路由：
```json
{
  // ... tailnet 策略文件的其他部分
  "derpMap": { "Regions": { "1": null } }
}
```
你可以从 `https://controlplane.tailscale.com/derpmap/default` 访问 Tailscale 的默认 DERP 地图：
```bash
curl https://controlplane.tailscale.com/derpmap/default
```
如果你安装了 `jq`，可以使用以下命令列出 Tailscale 的默认 DERP 区域及其 ID：
```bash
curl --silent https://controlplane.tailscale.com/derpmap/default | jq -r '.Regions[] | "\(.RegionID) \(.RegionName)"'
```
要确保你的流量仅通过自定义 DERP 服务器流动，请通过在 DERP 地图中将 `OmitDefaultRegions` 标志设置为 `true` 来删除所有 Tailscale 的默认 DERP 区域：
```json
{
  // ... tailnet 策略文件的其他部分
  "derpMap": {
    "OmitDefaultRegions": true,
    "Regions": {
      "900": {
        "RegionID": 900,
        "RegionCode": "myderp",
        "Nodes": [
          {
            "Name": "1",
            "RegionID": 900,
            "HostName": "example.com",
            // IPv4 和 IPv6 是可选的，但建议使用，以减少
            // 如果 DNS 不可用或出现问题时潜在的 DERP 连接问题。
            // 地址必须是可公开路由的，且不在私有 IP 范围内。
            "IPv4": "203.0.113.15",
            "IPv6": "2001:db8::1"
          }
        ]
      }
    }
  }
}
```
你可以在源代码的 [DERPMap 定义](https://pkg.go.dev/tailscale.com/tailcfg#DERPMap) 中访问 DERP 地图的完整选项集。

#### （可选）验证到自定义 DERP 服务器的客户端流量
任何知道你的 DERP 服务器 IP 地址的人都可以将其添加到他们的 DERP 地图中，并通过你的 DERP 服务器路由他们的 tailnet 流量。要仅允许你的 tailnet 流量通过你的 DERP 服务器，在与你的 DERP 服务器相同的设备上运行 `tailscaled`，并使用 `--verify-clients` 标志启动 `derper`：
```bash
sudo derper --hostname=example.com --verify-clients
```
### 监控自定义 DERP 服务器
使用 [cmd/derpprobe](https://github.com/tailscale/tailscale/tree/main/cmd/derpprobe) 二进制文件监控你的自定义 DERP 服务器，并验证它们是否正常工作。你需要指定一个 `--derp-map=file://` URL，该 URL 是一个包含要监控的 DERP 地图的 JSON 文档。

### 策略合规性
托管自定义 DERP 服务器的一个原因是确保策略合规性。例如，你可能有严格的策略要求，防止流量通过公共服务器，即使流量是加密的。

DERP 服务器仅转发加密流量，并且它们无法访问明文流量。此外，Tailscale 的 DERP 服务器是所有 Tailscale 客户共享的资源。你可能有严格的路由策略，例如防止加密流量穿过你无法控制的服务器。

为了符合此类策略，你可以运行一个或多个自定义 DERP 服务器，并从你的 tailnet 可以使用的 DERP 服务器列表中删除默认的 Tailscale DERP 服务器。
