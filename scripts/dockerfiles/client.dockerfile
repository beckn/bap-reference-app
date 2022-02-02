# client.dockerfile
# This dockerfile builds and runs the BAP client on port 9001.

# -- Build stage --

# Use the base image defined in `base.dockerfile`
FROM bap-base as build

# Copy the provided sources into the `sources/client` direcotry.
COPY ./sources/client /sources/client
# Move into the directory.
WORKDIR /sources/client
# Build the package.
RUN gradle clean build -x test --no-daemon

# -- Execute stage --

# Use JDK 11
FROM openjdk:11-jre-slim

# Copy over the built jar and configuration from the build stage.
COPY --from=build /sources/client/build/libs/sandbox_bap_client-*.*.*-SNAPSHOT.jar /app/client/client.jar
COPY --from=build /sources/client/src/main/resources/application.yml /app/client/config.yaml

# Run the client jar.
ENTRYPOINT [ "bash", "-c", "java -jar /app/client/client.jar -spring.config.location=file:///app/client/config.yaml" ]
# Expose the port 9001 to the world, that is where the client is listening for API calls.
EXPOSE 9001
