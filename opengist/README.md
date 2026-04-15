# opengist

[Office Web][1] - [Source][2] - [Docker Image][3] - [Document][4]

---

> [opengist][1] 是一个由 Git 提供支持的自托管粘贴。所有代码片段都存储在 Git 存储库中，可以使用标准 Git 命令或 Web 界面读取和/或修改。它类似于 [GitHub Gist](https://gist.github.com/)，但开源并且可以自托管。

[1]:https://opengist.io/
[2]:https://github.com/thomiceli/opengist
[3]:https://github.com/users/thomiceli/packages/container/package/opengist
[4]:https://opengist.io/docs

---

## 配置

### 使用 [`MEILISEARCH`](https://www.meilisearch.com/) 作为索引
1. 修改配置
```diff
- OG_INDEX=bleve
+ OG_INDEX=meilisearch
- OG_MEILI_HOST=none
+ OG_MEILI_HOST=http://meilisearch:7700
- OG_MEILI_API_KEY=none
+ OG_MEILI_API_KEY=master-key
```

2. 在后台更新索引：`管理` -> `通用` -> `动作` -> `索引所有 Gists`

3. 更新字段，否则会报 500 错误
```bash
curl -X PATCH 'http://meilisearch:7700/indexes/opengist/settings' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_MASTER_KEY' \
  -d '{
    "filterableAttributes": [
      "UserID",
      "Visibility",
      "Language",
      "Languages",
      "IsPublic",
      "Title",
      "GistID",
      "Owner",
      "FileName",
      "FileExtension",
      "Topic"
    ],
    "sortableAttributes": [
      "CreatedAt",
      "UpdatedAt",
      "Size"
    ]
  }'
```

### OIDC
- [回调地址](https://opengist.io/docs/configuration/oauth-providers.html)
```bash
http://opengist.url/oauth/openid-connect/callback
```
- 环境变量
```bash
OG_OIDC_PROVIDER_NAME=<provider-name>
OG_OIDC_CLIENT_KEY=<key>
OG_OIDC_SECRET=<secret>
# Discovery endpoint of the OpenID provider. Generally something like http://auth.example.com/.well-known/openid-configuration
OG_OIDC_DISCOVERY_URL=http://auth.example.com/.well-known/openid-configuration
```

---

## 注意事项

- 如果遇到权限问题，需要执行以下命令：
```bash
chmod -R 755 /opengist
```
