ARG NODE_IMAGE=node:24.22.2-trixie-slim

FROM ${NODE_IMAGE} AS base
WORKDIR /app
ENV NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_AUDIT=false
COPY package.json package-lock.json ./
COPY apps/backend/package.json apps/backend/

FROM base AS build
RUN --mount=type=cache,target=/root/.npm npm ci
COPY apps/backend apps/backend
RUN npm run build --workspace @careguide-task/backend

FROM base AS prod-deps
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev && rm -rf node_modules/@careguide-task

FROM ${NODE_IMAGE} AS runtime
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=8080 \
    LOG_LEVEL=info \
    TZ=UTC
WORKDIR /app
COPY --from=prod-deps --chown=root:root /app/node_modules ./node_modules
COPY --from=build --chown=root:root /app/apps/backend/build ./
USER 1000:1000
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["node", "-e", "fetch('http://127.0.0.1:'+process.env.PORT+'/').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
CMD ["node", "bin/server.js"]
