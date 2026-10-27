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

仓库的 `.github/workflows/docker-publish.yml` 会在推送到 `main` 后构建并发布 `ghcr.io/org100/word-atlas:latest`。首次使用前，在 GitHub 仓库的 Packages 页面将该镜像设为 Public，然后在项目根目录运行：

```bash
docker compose pull
docker compose up -d
```

打开 <http://localhost:5188>。停止服务：

```bash
docker compose down
```

可通过 `ATLAS_PORT` 修改本机端口，例如 `ATLAS_PORT=8080 docker compose up -d`。如果需要子路径部署，在项目根目录的 `.env` 中设置 `ATLAS_BASE=/words/`，再运行 `docker compose up -d --build`；这会用相同的路径构建前端并配置 Nginx。

## 体积

插画与音频合计约数百 MB。建议在 CDN 后部署，或按需只发布 `thumb/` 和部分音频。
