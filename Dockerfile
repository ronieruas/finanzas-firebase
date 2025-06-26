# 1. Use a more robust base image than Alpine to avoid potential compatibility issues.
# 'slim' is a good balance between size and compatibility.
FROM node:20-slim

# 2. Set the working directory inside the container.
WORKDIR /app

# 3. Copy all files from the build context to the current working directory.
# This is the most straightforward way to ensure all necessary files are present.
COPY . .

# 4. (DEBUG STEP) List the files to confirm `package.json` was copied.
RUN ls -la

# 5. Install the project dependencies.
RUN npm install

# 6. Build the Next.js application for production.
RUN npm run build

# 7. Expose the port that the Next.js app will run on.
EXPOSE 3000

# 8. Define the command to start the application when the container runs.
CMD ["npm", "start"]
