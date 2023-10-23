# Gitstats Docker

The Dockerfile inside this repository generates a folder with statistics of the repository and branch inputed by the user. It works only with github or azure repositories.

This project uses the Gitstats repository to generate the statistics: https://github.com/hoxu/gitstats.

## Usage instructions

To build the image you should use the commands based in the example below:

```bash
docker build --build-arg REPO=git@github.com:n1ghtr1der/gitstats-docker.git --build-arg REPO_NAME=gitstats-docker --build-arg SSH_PRV_KEY="$(cat path/to/private/key)" --build-arg BRANCH=main . -t gitstats
```

After build you need to run the container to copy the statistics to your computer:

Running the container:

```bash
docker run --name=gitstats-container -d gitstats tail -f /dev/null
```

Copying stats from container to host:

```bash
docker cp gitstats-container:/stats .
```

After copying the files from container, you should kill it.