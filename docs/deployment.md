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

直接下载仓库的 `docker-compose.yaml` 文件：

```bash
curl -O https://raw.githubusercontent.com/org100/word-atlas/main/docker-compose.yaml
```

若需自定义端口或部署路径，可在同级目录下新建 `.env` 环境变量文件：

```env
ATLAS_PORT=5188
ATLAS_BASE=/
```

拉取镜像并启动容器：

```bash
docker compose pull
docker compose up -d
```

启动后访问 `http://<服务器IP>:5188`。停止服务：`docker compose down`。

## Nginx Proxy Manager

如果 NPM 与本项目运行在同一个 Docker 网络（例如 `npm_default`），NPM 中无需使用 IP，直接通过容器名转发：

1. 在 NPM 中新增 **Proxy Host**：
   - **Domain Names**: 你的域名（如 `words.example.com`）
   - **Scheme**: `http`
   - **Forward Hostname / IP**: `word-atlas`（直接填写容器名）
   - **Forward Port**: `80`
2. 在 **SSL** 标签页申请 Let's Encrypt 证书并勾选 **Force SSL**。

## 体积

插画与音频合计约数百 MB。建议在 CDN 后部署，或按需只发布 `thumb/` 和部分音频。
