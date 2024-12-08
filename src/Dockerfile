# Use a Node.js base image
FROM node:14

# Create app directory in the container
WORKDIR /app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

# Install dependencies in the container
RUN npm install

# Install jq and other dependencies required by your script
RUN apt-get update && apt-get install -y jq curl

# Copy the Node.js server script and other necessary files into the container
COPY . .

# Set permissions for the shell script
RUN chmod +x ./list_ingress.sh

# Expose the port the app runs on
EXPOSE 8080

# Command to run the app
CMD [ "npm", "start" ]