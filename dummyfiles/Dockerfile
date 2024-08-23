# Use a base image
FROM node:14

# Set the working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the TypeScript application
RUN npm run build

# First CMD instruction (this will be overridden)
CMD ["node", "dist/index.js"]

# Second CMD instruction (this will override the first one)
CMD ["node", "dist/other.js"]

