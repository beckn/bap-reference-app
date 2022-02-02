# base.dockerfile
# This is the base image for all layers of the Beckn reference BAP. It builds
# and publishes (locally) the DTOs that are used by the different layers of
# the BAP.

# Use JDK 11
FROM gradle:jdk11

# Copy the provided sources into the `sources/protocol-dtos` direcotry.
COPY ./sources/protocol-dtos /sources/protocol-dtos
# Move into the directory.
WORKDIR /sources/protocol-dtos
# Build and publish the package.
RUN cd jvm && gradle clean autoVersion build publishToMavenLocal

# Do nothing
ENTRYPOINT ["bash", "-c", "tail --follow /dev/null"]
