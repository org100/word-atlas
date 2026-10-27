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

## Nginx Proxy Manager

推荐使用独立子域名，例如 `words.example.com`，并让 Nginx Proxy Manager（NPM）负责 HTTPS，应用容器继续使用 HTTP。

1. 在域名 DNS 中添加指向服务器公网 IP 的 A 记录，并确保公网 80、443 端口可到达 NPM。
2. 在 NPM 的 **Hosts → Proxy Hosts → Add Proxy Host** 中填写：

| NPM 字段 | 值 |
| :--- | :--- |
| Domain Names | `words.example.com` |
| Scheme | `http` |
| Forward Hostname / IP | 运行 Docker Compose 的主机 IP，例如 `192.168.1.20` |
| Forward Port | `5188` |
| Websockets Support | 关闭（本站是静态站点） |
| Block Common Exploits | 开启 |

3. 在 **SSL** 标签页申请 Let's Encrypt 证书，开启 **Force SSL** 和 **HTTP/2 Support**，保存后用 `https://words.example.com` 访问。

如果 NPM 运行在 Docker 容器里，转发地址不能填 `localhost`，因为它指向 NPM 容器自身；填写 Docker 主机可从 NPM 容器访问的 IP。若 NPM 是直接安装在 Docker 主机上的进程，转发地址可用 `127.0.0.1`，端口仍为 `5188`。NPM 的标准 Proxy Host 表单已包含所需转发头，无需填写自定义 Advanced Nginx 配置。

## 体积

插画与音频合计约数百 MB。建议在 CDN 后部署，或按需只发布 `thumb/` 和部分音频。
