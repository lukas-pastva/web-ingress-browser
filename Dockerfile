# Use a maintained Node.js base image (Debian-based)
FROM node:20

# Create app directory in the container
WORKDIR /app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY ./src/package*.json ./

# Install dependencies in the container
RUN npm install

# Install jq and curl required by the script
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq curl \
    && rm -rf /var/lib/apt/lists/*

# Copy the Node.js server script and other necessary files into the container
COPY ./src .

# Set permissions for the shell script
RUN chmod +x ./list_ingress.sh

# Expose the port the app runs on
EXPOSE 8080

# Command to run the app
CMD [ "npm", "start" ]
