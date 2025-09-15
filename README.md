# FSI Tutorial Docker Container

This Docker container provides a ready-to-use environment for the **Turek–Hron FSI3 tutorial** with preCICE, deal.II, and OpenFOAM.  

It includes:  
- preCICE library  
- deal.II adapter (`dealii-adapter`)  
- OpenFOAM adapter (with executables in `$PATH`)  
- OpenFOAM executables (`blockMesh`, `icoFoam`, `simpleFoam`, etc.)  
- Tutorial materials: only `tools/` and `turek-hron-fsi3/`  

Students will build the solver themselves as part of the exercise.

---

## 1. Install Docker

- **Linux**: Install via your package manager or from [Docker Docs](https://docs.docker.com/get-docker/)  
- **Windows / macOS**: Install **Docker Desktop** from [Docker Docs](https://docs.docker.com/desktop/)  

Verify installation:

```bash
docker --version
```

---

## 2. Pull the course image

Pull the ready-to-use Docker image. Run:

```bash
docker pull <your-dockerhub-username>/fsi-tutorial:latest
```
---

## 3. Run the container

Start an interactive session with:

```bash
docker run -it --rm \
    -v $(pwd):/home/student/project \  # Mount project directory
    <your-dockerhub-username>/fsi-tutorial:latest
```

The -it flag allows interactive terminal access. The --rm flag removes the container after exit. The
-v flag mounts your current directory to /home/student/project in the container.

You will start in /home/student/project. Anything saved here will persist on your host machine.

---
