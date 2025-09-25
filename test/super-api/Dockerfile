# Use Node.js 18 Alpine image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --legacy-peer-deps

# Copy source code
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Expose port
EXPOSE 4001

# Start the application in development mode
CMD ["npm", "run", "dev"]
