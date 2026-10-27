FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
ARG ATLAS_BASE=/
ENV ATLAS_BASE=${ATLAS_BASE}
RUN npm run build

FROM nginx:alpine AS runtime

ENV ATLAS_BASE=/
COPY docker/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/dist/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider "http://127.0.0.1$ATLAS_BASE" || exit 1
