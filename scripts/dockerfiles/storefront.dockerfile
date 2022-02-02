# ui.dockerfile
# This is the docker image for running the Vue Storefront UI of the BAP.

# -- Build stage --

FROM node:14.18.1-alpine as build

# Install necessary packages
RUN apk update
RUN apk add g++ make python3 git

# Copy the provided sources into the `app` direcotry.
COPY ./sources/storefront /app
COPY ./storefront.entrypoint /app
WORKDIR /app

# Build the package
RUN yarn install
RUN yarn build

# -- Execute stage --

FROM nginx:1.19.7-alpine

# Install necessary packages
RUN apk update && apk upgrade
RUN apk add --no-cache nodejs=14.18.1-r0 npm=14.18.1-r0
RUN npm install -g yarn

# Copy over the built application to the `/usr/share/nginx/html` directory, so
# we can serve it from there.
COPY --from=build /app /usr/share/nginx/html
COPY --from=build /app/nginx.conf.j2 /etc/nginx/nginx.conf

# Set the application entrypoint
WORKDIR /usr/share/nginx/html
RUN chmod +x ./storefront.entrypoint
CMD ["bash", "./storefront.entrypoint"]

# Export port 8080, which 
EXPOSE 8080
