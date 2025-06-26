# Firebase Studio

This is a NextJS starter in Firebase Studio.

To get started, take a look at src/app/page.tsx.

---

## Deployment with Docker on Proxmox

This section provides instructions on how to deploy this application using Docker, which you can then run inside a VM or LXC container on Proxmox.

### Prerequisites

*   Docker installed on your local machine or on the Proxmox guest (VM/LXC).
*   Access to your Proxmox server.
*   Your project code hosted in a Git repository (e.g., GitHub).

### Step 1: Prepare the Proxmox Guest

1.  **Create a VM or LXC:** On your Proxmox server, create a new Virtual Machine (e.g., with Debian or Ubuntu Server) or an LXC container.
2.  **Install Git and Docker:** Access the guest's terminal and install Git and Docker.
    ```bash
    # Example for Debian/Ubuntu
    sudo apt-get update
    sudo apt-get install -y git docker.io
    ```
3.  **Clone Your Repository:** Clone your project from GitHub into the Proxmox guest.
    ```bash
    git clone <URL_DO_SEU_REPOSITORIO_GIT>
    cd <NOME_DO_SEU_PROJETO>
    ```

### Step 2: Build the Docker Image

From the root directory of your cloned project, run the following command to build the Docker image. This will package your application into a self-contained unit.

```bash
docker build -t finanzas-zen .
```
This command creates an image named `finanzas-zen`.

### Step 3: Run the Docker Container

Once the image is built, you can run it as a container.

```bash
docker run -p 8080:3000 --name finanzas-zen-app -d --restart always finanzas-zen
```

**Explanation of the command:**
*   `docker run`: The command to start a new container.
*   `-p 8080:3000`: Maps port `8080` on your Proxmox guest to port `3000` inside the container (where the Next.js app is running). You can change `8080` to any other available port.
*   `--name finanzas-zen-app`: Gives your container a memorable name.
*   `-d`: Runs the container in detached mode (in the background).
*   `--restart always`: Ensures the container automatically restarts if it crashes or the server reboots.
*   `finanzas-zen`: The name of the image to use.

Your application is now deployed and running! It should be accessible at `http://<IP_DO_SEU_PROXMOX_GUEST>:8080`.
