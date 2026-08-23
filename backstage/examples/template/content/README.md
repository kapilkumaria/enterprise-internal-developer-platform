# ${{ values.name }}

${{ values.description }}

Generated through the **Enterprise Internal Developer Platform** using Backstage Software Templates.

## Run locally

```bash
npm install
npm start
```

The service listens on port `3000`.

## Health endpoint

```bash
curl http://localhost:3000/health
```

## Test

```bash
npm test
```

## Container

```bash
docker build -t ${{ values.name }}:local .
docker run --rm -p 3000:3000 ${{ values.name }}:local
```

## Platform capabilities

This repository was bootstrapped with:

- Backstage catalog metadata
- Node.js service baseline
- Docker containerization
- Kubernetes deployment manifests
- Workload securityContext
- Resource requests and limits
- Readiness and liveness probes
- GitHub Actions CI
- TechDocs
