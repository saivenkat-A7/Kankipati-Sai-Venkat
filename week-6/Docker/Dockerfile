# Use Node base image
FROM node:20


# Create application directory
WORKDIR /app


# Copy package files
COPY package*.json ./


# Install dependencies
RUN npm install


# Copy application code
COPY . .


# Application port
EXPOSE 3000


# Start application
CMD ["node","app.js"]