# protocol.dockerfile
# This dockerfile builds and runs the BAP protocol helper on port 9002.

# -- Build stage --

# Use the base image defined in `base.dockerfile`
FROM bap-base as build

# Copy the provided sources into the `sources/protocol-helper` direcotry.
COPY ./sources/protocol-helper /sources/protocol-helper
# Move into the directory.
WORKDIR /sources/protocol-helper
# Build the package.
RUN gradle clean build -x test --no-daemon

# -- Execute stage --

# Use JDK 11
FROM openjdk:11-jre-slim

# Copy over the built jar and configuration from the build stage.
COPY --from=build /sources/protocol-helper/build/libs/sandbox_bap_protocol-*.*.*-SNAPSHOT.jar /app/protocol-helper/protocol-helper.jar
COPY --from=build /sources/protocol-helper/src/main/resources/application.yml /app/protocol-helper/config.yaml

# Run the protocol helper jar.
ENTRYPOINT [ "bash", "-c", "java -jar /app/protocol-helper/protocol-helper.jar -spring.config.location=file:///app/protocol-helper/config.yaml" ]
# Expose the port 9002 to the world, that is where the protocol helper is listening for API calls.
EXPOSE 9002
