# Use Node.js 14 LTS version as the base image
FROM node:14

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the entire project directory to the working directory
COPY . .

# Expose port 3000 for the React application
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
