FROM node:18-alpine

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies if node_modules doesn't exist
RUN if [ ! -d "node_modules" ]; then npm install --registry https://registry.npmmirror.com; fi

# Copy node_modules if they exist (for pre-installed dependencies)
COPY node_modules* ./node_modules/

# Copy application source
COPY src ./src
COPY public ./public

# Set environment variable
ENV REACT_APP_API_URL=http://localhost:8080

EXPOSE 3000

CMD ["npm", "start"]