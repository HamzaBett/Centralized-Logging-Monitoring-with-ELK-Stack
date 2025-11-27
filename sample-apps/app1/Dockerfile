# Sample App 1 Dockerfile
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json .

# Install dependencies
RUN npm install --production

# Copy application files
COPY app.js .

# Expose port
EXPOSE 3000

# Start the application
CMD ["node", "app.js"]
