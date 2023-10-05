# Use an official Node.js runtime as the parent image
FROM node:14

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install the application dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY apiServer.js .

# Expose the application on ports 3000 and 5050
EXPOSE 3000 5050

# Run the application
CMD ["node", "apiServer.js"]
