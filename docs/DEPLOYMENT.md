# Deployment Guide

This guide covers deploying Larry to production environments.

## Prerequisites

- Docker and Docker Compose
- PostgreSQL database (managed or self-hosted)
- Redis instance
- Domain name and SSL certificate
- Environment variables configured

## Production Architecture

### Recommended Setup
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │   CDN/Static    │    │   Monitoring    │
│   (nginx/ALB)   │    │   (CloudFront)  │    │   (DataDog)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Backend API   │    │   Frontend App  │    │   Database      │
│   (Node.js)     │    │   (React Native)│    │   (PostgreSQL)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cache Layer   │    │   File Storage  │    │   Backup        │
│   (Redis)       │    │   (S3/R2)       │    │   (S3/R2)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Environment Setup

### 1. Production Environment Variables

Create `.env.production`:

```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/larry_prod
REDIS_URL=redis://host:6379

# JWT
JWT_SECRET=your-super-secure-jwt-secret-here
JWT_REFRESH_SECRET=your-super-secure-refresh-secret-here

# OpenAI
OPENAI_API_KEY=your-openai-api-key

# OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
APPLE_CLIENT_ID=your-apple-client-id

# App
NODE_ENV=production
PORT=4000
CORS_ORIGIN=https://yourdomain.com

# Monitoring
SENTRY_DSN=your-sentry-dsn
DATADOG_API_KEY=your-datadog-key

# Storage
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_REGION=us-east-1
S3_BUCKET=larry-assets

# Backup
BACKUP_S3_BUCKET=larry-backups
BACKUP_RETENTION_DAYS=30
```

### 2. Database Setup

#### Option A: Managed PostgreSQL (Recommended)

**AWS RDS**:
```bash
# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier larry-prod \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username larry \
  --master-user-password secure-password \
  --allocated-storage 20 \
  --storage-encrypted
```

**Google Cloud SQL**:
```bash
# Create Cloud SQL instance
gcloud sql instances create larry-prod \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --storage-type=SSD \
  --storage-size=20GB
```

#### Option B: Self-Hosted PostgreSQL

```yaml
# docker-compose.prod.yml
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: larry_prod
      POSTGRES_USER: larry
      POSTGRES_PASSWORD: secure-password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    ports:
      - "5432:5432"
```

### 3. Redis Setup

#### Option A: Managed Redis

**AWS ElastiCache**:
```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id larry-cache \
  --engine redis \
  --cache-node-type cache.t3.micro \
  --num-cache-nodes 1
```

**Google Cloud Memorystore**:
```bash
gcloud redis instances create larry-cache \
  --size=1 \
  --region=us-central1 \
  --redis-version=redis_7_0
```

#### Option B: Self-Hosted Redis

```yaml
# docker-compose.prod.yml
services:
  redis:
    image: redis:7-alpine
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
```

## Docker Production Setup

### 1. Production Dockerfile

```dockerfile
# api/Dockerfile.prod
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

FROM node:20-alpine AS runtime

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

EXPOSE 4000
CMD ["node", "dist/index.js"]
```

### 2. Production Docker Compose

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  backend:
    build:
      context: ./api
      dockerfile: Dockerfile.prod
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - JWT_SECRET=${JWT_SECRET}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    ports:
      - "4000:4000"
    restart: unless-stopped
    depends_on:
      - postgres
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: larry_prod
      POSTGRES_USER: larry
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U larry"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

### 3. Nginx Configuration

```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:4000;
    }

    server {
        listen 80;
        server_name yourdomain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name yourdomain.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            access_log off;
            proxy_pass http://backend;
        }
    }
}
```

## Deployment Steps

### 1. Database Migration

```bash
# Run migrations
docker compose -f docker-compose.prod.yml exec backend npx prisma migrate deploy

# Verify database
docker compose -f docker-compose.prod.yml exec backend npx prisma studio
```

### 2. Deploy Application

```bash
# Build and start services
docker compose -f docker-compose.prod.yml up -d --build

# Check status
docker compose -f docker-compose.prod.yml ps

# View logs
docker compose -f docker-compose.prod.yml logs -f backend
```

### 3. Health Checks

```bash
# Check API health
curl https://yourdomain.com/health

# Check database connection
docker compose -f docker-compose.prod.yml exec backend npx prisma db seed

# Check Redis connection
docker compose -f docker-compose.prod.yml exec redis redis-cli ping
```

## Monitoring & Logging

### 1. Application Monitoring

```javascript
// api/src/monitoring.js
import { DataDog } from 'datadog-api-client';

const datadog = new DataDog({
  apiKey: process.env.DATADOG_API_KEY,
  appKey: process.env.DATADOG_APP_KEY,
});

export const monitor = {
  increment: (metric) => datadog.metrics.increment(metric),
  gauge: (metric, value) => datadog.metrics.gauge(metric, value),
  timing: (metric, duration) => datadog.metrics.timing(metric, duration),
};
```

### 2. Logging

```javascript
// api/src/logger.js
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

export default logger;
```

### 3. Health Checks

```javascript
// api/src/health.js
export const healthCheck = async (req, res) => {
  try {
    // Check database
    await prisma.$queryRaw`SELECT 1`;
    
    // Check Redis
    await redis.ping();
    
    // Check OpenAI
    await openai.models.list();
    
    res.json({
      ok: true,
      timestamp: new Date().toISOString(),
      services: {
        database: 'healthy',
        redis: 'healthy',
        openai: 'healthy',
      },
    });
  } catch (error) {
    res.status(503).json({
      ok: false,
      error: error.message,
      services: {
        database: 'unhealthy',
        redis: 'unhealthy',
        openai: 'unhealthy',
      },
    });
  }
};
```

## Backup Strategy

### 1. Database Backups

```bash
#!/bin/bash
# scripts/prod-backup.sh

# Create backup
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d_%H%M%S).sql

# Compress
gzip backup_*.sql

# Upload to S3
aws s3 cp backup_*.sql.gz s3://$BACKUP_S3_BUCKET/

# Clean up local files
rm backup_*.sql.gz

# Clean up old backups (keep 30 days)
aws s3 ls s3://$BACKUP_S3_BUCKET/ | \
  awk '$1 < "'$(date -d '30 days ago' +%Y-%m-%d)'" {print $4}' | \
  xargs -I {} aws s3 rm s3://$BACKUP_S3_BUCKET/{}
```

### 2. Automated Backups

```yaml
# docker-compose.prod.yml
services:
  backup:
    image: postgres:15
    environment:
      - PGPASSWORD=${DB_PASSWORD}
    volumes:
      - ./scripts:/scripts
      - ./backups:/backups
    command: >
      sh -c "
        while true; do
          /scripts/prod-backup.sh
          sleep 86400
        done
      "
    depends_on:
      - postgres
```

## Security

### 1. SSL/TLS

```bash
# Generate SSL certificate
certbot certonly --standalone -d yourdomain.com

# Copy certificates
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./ssl/cert.pem
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./ssl/key.pem
```

### 2. Firewall

```bash
# UFW configuration
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw deny 5432/tcp
ufw deny 6379/tcp
ufw enable
```

### 3. Environment Security

```bash
# Generate secure secrets
openssl rand -hex 32  # JWT_SECRET
openssl rand -hex 32  # JWT_REFRESH_SECRET
```

## Scaling

### 1. Horizontal Scaling

```yaml
# docker-compose.prod.yml
services:
  backend:
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    environment:
      - REDIS_URL=redis://redis-cluster:6379
```

### 2. Load Balancer

```nginx
# nginx.conf
upstream backend {
    server backend1:4000;
    server backend2:4000;
    server backend3:4000;
}
```

### 3. Database Scaling

```bash
# Read replicas
aws rds create-db-instance-read-replica \
  --db-instance-identifier larry-read-replica \
  --source-db-instance-identifier larry-prod
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   ```bash
   # Check database status
   docker compose -f docker-compose.prod.yml exec postgres pg_isready
   
   # Check logs
   docker compose -f docker-compose.prod.yml logs postgres
   ```

2. **Redis Connection Failed**
   ```bash
   # Check Redis status
   docker compose -f docker-compose.prod.yml exec redis redis-cli ping
   
   # Check logs
   docker compose -f docker-compose.prod.yml logs redis
   ```

3. **API Not Responding**
   ```bash
   # Check backend status
   curl http://localhost:4000/health
   
   # Check logs
   docker compose -f docker-compose.prod.yml logs backend
   ```

### Performance Monitoring

```bash
# Monitor resource usage
docker stats

# Check API response times
curl -w "@curl-format.txt" -o /dev/null -s "https://yourdomain.com/health"

# Monitor database performance
docker compose -f docker-compose.prod.yml exec postgres psql -U larry -d larry_prod -c "SELECT * FROM pg_stat_activity;"
```

## Rollback Strategy

### 1. Database Rollback

```bash
# Restore from backup
pg_restore -d larry_prod backup_20250101_120000.sql

# Or use point-in-time recovery
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier larry-prod \
  --target-db-instance-identifier larry-prod-rollback \
  --restore-time 2025-01-01T12:00:00Z
```

### 2. Application Rollback

```bash
# Rollback to previous version
docker compose -f docker-compose.prod.yml down
docker tag larry-backend:previous larry-backend:latest
docker compose -f docker-compose.prod.yml up -d
```

## Cost Optimization

### 1. Resource Optimization

```yaml
# docker-compose.prod.yml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 256M
        reservations:
          cpus: '0.1'
          memory: 128M
```

### 2. Auto-scaling

```bash
# AWS Auto Scaling Group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name larry-asg \
  --min-size 1 \
  --max-size 5 \
  --desired-capacity 2 \
  --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/larry-tg
```

This deployment guide provides a comprehensive approach to deploying Larry in production with proper monitoring, security, and scalability considerations.
