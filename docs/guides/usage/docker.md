# Docker Deployment Guide

This guide walks you through running the Beckn in a Box application using
`docker` and `docker-compose`.

## Prerequisites

> This guide assumes a some familiarity with basic linux commands. If not,
> [here](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview) is
> a great place to start.

> Note: Don't copy-paste the `>` signs at the beginning, they indicate that what
> follows is a terminal command

### Terminal emulator

Linux and MacOS will have a terminal installed already. For Windows, it is
recommended that you use `git-bash`, which you can install from
[here](https://git-scm.com/download/win).

Type `echo Hi` in the terminal once it is installed. If installed correctly, you
should see `Hi` appear when you hit enter.

### Docker

Installation instructions for Docker can be found
[here](https://docs.docker.com/engine/install/).

Run `docker -v` in terminal to check if `docker` has been installed correctly:

```sh
$ docker -v
Docker version 20.10.12, build e91ed5707e
```

### Docker Compose

Installation instructions can be found
[here](https://docs.docker.com/engine/install/).

Run `docker-compose -v` in terminal to check if `docker-compose` has been
installed correctly:

```sh
$ docker-compose -v
Docker Compose version 2.2.3
```

## Running the application

### BAP Storefront UI

You can run the BAP Storefront UI application via the docker compose file given
in the `deploy/` folder -
[`deploy/docker-compose.yaml`](/deploy/docker-compose.yaml). Simply download the
file to, say, `Downloads/docker-compose.yaml` and run the following in terminal:

```
# Move into the `Downloads` folder.
> cd Downloads
# Run the app using Docker Compose.
> docker compose up
```

This will pull all the images and start running the application. Once the build
process has finished, browse to [`http://localhost:3000`](http://localhost:3000)
and start using the storefront application!

If you are facing any problems or have any questions, please don't hesitate to
[start a discussion on GitHub](https://github.com/beckn/bap-reference-app/discussions/new).

### Using the Individual Components

Each component is packaged into its own image, so you can use it in your own
project too. The dockerfiles used to build each image can be found
[here](/scripts/dockerfiles).

#### Beckn Protocol Client

The [`client` component](/readme.md#beckn-protocol-client) image can be found at
`ghcr.io/beckn/bap-client`. To use it, simply `pull` it using `docker`:

```
> docker pull ghcr.io/beckn/bap-client
```

To run the Beckn protocol client on port 9001, and tell it to use the Mongo
database running on port 27017:

```
> docker run -p 9001:9001 --env DATABASE_URL=mongodb://localhost:27017 ghcr.io/beckn/bap-client
```

#### Protocol Helper

The [`protocol-helper` component](/readme.md#protocol-helper) image can be found
at `ghcr.io/beckn/bap-protocol-helper`. To use it, simply `pull` it using
`docker`:

```
> docker pull ghcr.io/beckn/bap-protocol-helper
```

To run the Beckn protocol helper on port 9002, and tell it to use the Mongo
database running on port 27017:

```
> docker run -p 9002:9002 --env DATABASE_URL=mongodb://localhost:27017 ghcr.io/beckn/bap-protocol-helper
```

#### Protocol DTOs

The `bap-client` and `bap-protocol-helper` images are built based off the
[`bap-base`](/readme.md#protocol-dtos) image, which can be `pull`ed using
`docker`:

```
> docker pull ghcr.io/beckn/bap-base
```

#### UI Layer

The [`storefront-ui`](/readme.md#ui-layer) component itself is also packaged as
a docker image:

```
docker pull ghcr.io/beckn/bap-storefront
```

To run the storefront UI on port 3000:

```
> docker run -p 3000:3000 ghcr.io/beckn/bap-storefront
```

If you are facing any problems or have any questions, please don't hesitate to
[start a discussion on GitHub](https://github.com/beckn/bap-reference-app/discussions/new).
