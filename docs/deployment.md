# 部署 / Deployment

`npm run build` 生成纯静态站点 `dist/`，可以放到任何静态托管（Nginx、Cloudflare Pages、Vercel、GitHub Pages）。

## 子路径

```bash
ATLAS_BASE=/words/ npm run build
```

## Nginx 示例

```nginx
location ^~ /words/ {
    alias /var/www/word-atlas/;
    try_files $uri $uri/ /words/index.html;
    expires 7d;
}
```

## GitHub Pages

仓库带有 `.github/workflows/pages.yml`。在仓库 Settings → Pages 选择 “GitHub Actions”，然后手动运行 “Deploy to GitHub Pages”。

## Docker Compose

直接拉取配置文件并启动容器：

```bash
curl -O https://raw.githubusercontent.com/org100/word-atlas/main/docker-compose.yaml
docker compose pull
docker compose up -d
```

打开 `http://localhost:5188`。停止服务运行 `docker compose down`。

如需修改端口或配置子路径，可在同级目录新建 `.env` 文件：

```env
ATLAS_PORT=5188
ATLAS_BASE=/
```

## Nginx Proxy Manager

如果 NPM 与本项目运行在同一个 Docker 网络（例如 `npm_default`），确保 `docker-compose.yaml` 中已加入该网络：

```yaml
services:
  word-atlas:
    # ... 保持原有配置 ...
    networks:
      - npm_default

networks:
  npm_default:
    external: true
```

在 NPM 中无需填写 IP，直接通过容器名转发：

1. 在 NPM 的 **Hosts → Proxy Hosts → Add Proxy Host** 中填写：
   - **Domain Names**: 你的域名（如 `words.example.com`）
   - **Scheme**: `http`
   - **Forward Hostname / IP**: `word-atlas`（直接填写容器名）
   - **Forward Port**: `80`
   - **Block Common Exploits**: 开启
2. 在 **SSL** 标签页申请 Let's Encrypt 证书，勾选 **Force SSL** 和 **HTTP/2 Support**。

## 体积

插画与音频合计约数百 MB。建议在 CDN 后部署，或按需只发布 `thumb/` 和部分音频。
