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

# Docker 与 Nginx Proxy Manager 部署配置指南

本文档包含了重构后的规范配置文件及完整的 `docs/deployment.md` 部署指南。

---

## 1. 规范的 `docker-compose.yml`

将以下内容保存到项目根目录的 `docker-compose.yml`：

```yaml
services:
  word-atlas:
    image: ghcr.io/org100/word-atlas:latest
    build:
      context: .
      args:
        ATLAS_BASE: ${ATLAS_BASE:-/}
    pull_policy: missing
    container_name: word-atlas
    environment:
      ATLAS_BASE: ${ATLAS_BASE:-/}
    ports:
      - "${ATLAS_PORT:-5188}:80"
    restart: unless-stopped
    networks:
      - npm_default

networks:
  npm_default:
    external: true
```

---

## 2. 规范的 `docs/deployment.md`

将以下完整内容替换或写入到 `docs/deployment.md` 文件中：

```markdown
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

## Docker Compose 部署

项目包含默认的 `docker-compose.yml`，官方提供预构建镜像 `ghcr.io/org100/word-atlas:latest`。

### 1. 基础部署（直接暴露端口）

在项目根目录创建 `.env`（可选）：
```env
ATLAS_PORT=5188
ATLAS_BASE=/
```

拉取并启动服务：
```bash
docker compose pull
docker compose up -d
```
启动后访问：`http://<服务器IP>:5188`。

---

### 2. 本地从源码构建（含子路径部署）

如果需要自定义构建或配置子路径（例如部署在 `/words/` 下）：

1. 修改 `.env` 文件：
   ```env
   ATLAS_PORT=5188
   ATLAS_BASE=/words/
   ```
2. 执行构建并启动：
   ```bash
   docker compose up -d --build
   ```

---

### 3. 停止与常用命令

* **停止服务**：`docker compose down`
* **查看日志**：`docker compose logs -f`
* **更新镜像**：`docker compose pull && docker compose up -d`

## Nginx Proxy Manager (NPM) 结合部署

推荐使用独立子域名（如 `words.example.com`），并由 NPM 统一处理 SSL/HTTPS。根据 NPM 的安装方式，提供以下两种最佳实践配置：

### 方式 A：通过外部 Docker 网络加入 NPM（推荐）

如果 NPM 也以 Docker 容器形式运行，建议将应用容器加入 NPM 的 `npm_default` 网络，无需暴露公网端口。

在 `docker-compose.yml` 中配置：
```yaml
services:
  word-atlas:
    image: ghcr.io/org100/word-atlas:latest
    container_name: word-atlas
    pull_policy: missing
    restart: unless-stopped
    environment:
      ATLAS_BASE: ${ATLAS_BASE:-/}
    networks:
      - npm_default

networks:
  npm_default:
    external: true
```

**NPM Proxy Host 配置：**
* **Domain Names**: `words.example.com`
* **Scheme**: `http`
* **Forward Hostname / IP**: `word-atlas`（直接填容器名）
* **Forward Port**: `80`

---

### 方式 B：通过宿主机 IP / 端口转发（独立安装/暴露端口模式）

如果 NPM 直接安装在宿主机上，或不想使用容器网络互通：

1. 确保 `docker-compose.yml` 正常暴露了宿主机端口（默认 `5188`）。
2. 在 NPM 中新增 **Proxy Host**：
   * **Domain Names**: `words.example.com`
   * **Scheme**: `http`
   * **Forward Hostname / IP**: 宿主机 IP（若 NPM 在容器内，填局域网 IP 如 `192.168.1.20`，不可填 `localhost`；若 NPM 在宿主机，可填 `127.0.0.1`）
   * **Forward Port**: `5188`

3. 在 **SSL** 标签页中申请 Let's Encrypt 证书，并勾选 **Force SSL** 和 **HTTP/2 Support**。

## 体积

插画与音频合计约数百 MB。建议在 CDN 后部署，或按需只发布 `thumb/` 和部分音频。
``

## 体积

插画与音频合计约数百 MB。建议在 CDN 后部署，或按需只发布 `thumb/` 和部分音频。
