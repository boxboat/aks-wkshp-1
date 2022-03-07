---
# Page settings
layout: default
keywords:
comments: false

# Hero section
title: Lab - Docker
description: Let's get started with Docker! 

# Author box
author:
    title: About Author
    title_url: '#'
    external_url: true
    description: Faheem is a senior solutions architect at BoxBoat. He's delivered projects n various clouds. Azure remains his favorite.

# Micro navigation
micro_nav: true

# Page navigation
page_nav:
    prev:
        content: Home
        url: '/'
    next:
        content: Lab - Kubernetes
        url: '/lab-kubernetes'
---

## Install Docker Desktop

Link: [Docker Desktop](https://www.docker.com/products/docker-desktop)

Once you have the Docker Desktop installed on your computer, launch a terminal and type the following command.

```shell
docker version

# response
Client: Docker Engine - Community
 Cloud integration: 1.0.4
 Version:           20.10.2
 API version:       1.41
 Go version:        go1.13.15
 Git commit:        2291f61
 Built:             Mon Dec 28 16:12:42 2020
 OS/Arch:           darwin/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.2
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.13.15
  Git commit:       8891c58
  Built:            Mon Dec 28 16:15:23 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.4.3
  GitCommit:        269548fa27e0089a8b8278fc4fc781d7f65a939b
 runc:
  Version:          1.0.0-rc92
  GitCommit:        ff819c7e9184c13b7c2607fe6c30ae19403a7aff
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

`docker version` command shows you information regarding the client (Desktop CLI) and serer (Desktop Engine).

## Pull and launch a container
You can pull pre-built container images from external registries such as [Docker Hub](https://hub.docker.com). Let's pull and launch an `alpine` container.

**Step 1: Pull the container**
```shell
docker pull alpine

# response
Using default tag: latest
latest: Pulling from library/alpine
801bfaa63ef2: Pull complete 
Digest: sha256:3c7497bf0c7af93428242d6176e8f7905f2201d8fc5861f45be7a346b5f23436
Status: Downloaded newer image for alpine:latest
docker.io/library/alpine:latest
```

**Step 2: Run the container and connect shell into it**
```shell
docker run --name alpine -ti alpine
# _
```
Docker CLI will launch the container, and you can run commands inside the Linux container. Please note that any file changes you make in this container will be ephemeral. For containers that need to preserve file changes, you need to mound an external volume into the container.

**Step 3: Stop and delete the container**
You can `exit` out of the shell. It will also stop the container since there was no long-running process inside it. For example, in case of other applications, a web server will continue running as long as the web server process is running. Once your container is stopped, you can remove the container instance from the system.

```shell
docker rm alpine
```

## Launch a webserver

**Step 1: Launch a webserver container.**

```shell
docker run --name hello-world -d -p 80:80 boxboat/hello-world
```

Notice that we didn't explicitly pull the `boxboat/hello-world` image from Docker hub. The CLI will notice that I don't have the image and it will pull it automatically.
 
 * `-n` gives the container a name so you can interact 
 * `-d` runs the container in detached mode, which means the container will run in the background and we don't get shell into it.
 * `-p` maps the container network port with your host network. Containers run in a separate virtual network. Docker desktop helps you do the mapping between the two interfaces.

 **Step 2: Check the running containers**
 
 ```shell
 docker ps

 #response
 CONTAINER ID   IMAGE                 COMMAND                  CREATED          STATUS          PORTS                NAMES
b3c75af0d067   boxboat/hello-world   "/opt/hello-world/he…"   22 seconds ago   Up 18 seconds   0.0.0.0:80->80/tcp   hello-world
```
`docker ps` shows all running containers. We only have one at this point. You can also see the port mappings. You should be able to open a browser and view the website [http://localhost](http://localhost:80)

**Step 3: Check container logs**
```shell
docker logs hello-world
```

**Step 4: Exec into the container**
```shell
docker exec -ti hello-world sh
```
Look around inside the container and when you are done, `exit` out of it.

**Step 5: Stop and cleanup**
```shell
docker stop hello-world
docker rm hello-world
```

You can learn more about Docker CLI command [reference](https://docs.docker.com/engine/reference/commandline/docker/)

## Build container images

You can use a `Dockerfile` to build new container images. Dockerfile provides a simple syntax for building Linux or Windows containers. You can learn more about the Dockerfile [reference](https://docs.docker.com/engine/reference/builder/) Let's build a container for funfact application.

```shell
git clone git@github.com:faheem556/funfact.git
cd funfact

# build dotnet app
docker build -t funfact:dotnet-1-0 -f dotnet/Dockerfile ./dotnet

# build node image
docker build -t funfact:node-1-0 -f nodejs/Dockerfile ./nodejs

# build java image
docker build -t funfact:java-1-0 -f java/Dockerfile ./java
```

Example Dockerfile
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "funfact.dll"]
```


Read through the code and docker files to understand the environment. It's straight-forward.

Let's run the application now.

```shell
docker run --name funfactd -d --rm -p 8080:80 funfact:dotnet-1-0 
docker run --name funfactn -d --rm -p 8081:80 funfact:node-1-0 
docker run --name funfactj -d --rm -p 8082:80 funfact:java-1-0 
docker ps
```

You should have three running containers at this point. If the container doesn't start for some reason, you can use `docker ps -a' and `docker log` to troubleshoot.

Once the containers are up, open your browsers and try out the applications.

**Cleanup**
```shell
docker stop funfactd
docker rm funfactd

docker stop funfactn
docker rm funfactd

docker stop funfactj
docker rm funfactj
```
