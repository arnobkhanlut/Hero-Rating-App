FROM node:9.4.0-alpine

ARG VCS_REF
ARG BUILD_DATE
ARG IMAGE_TAG_REF
ARG APISERVER

ENV GIT_SHA $VCS_REF
ENV IMAGE_BUILD_DATE $BUILD_DATE
ENV IMAGE_TAG $IMAGE_TAG_REF
ENV APISERVER $APISERVER

WORKDIR /usr/src/app
COPY ./web/package*.json ./
RUN npm install

COPY ./web .
RUN apk --no-cache add curl
EXPOSE 8080

CMD [ "npm", "run", "container" ]