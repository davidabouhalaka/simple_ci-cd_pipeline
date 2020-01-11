FROM maven:3.3.9-jdk-8

ARG RELEASE_VERSION=1.0.0-SNAPSHOT

ARG API_NAME=blogpost-api

ARG API_BUILD_DIR=/opt/usr/src

ARG APP_HOME_DIR=/var/www/app

ARG SPRING_PROFILES_ACTIVE=dev

ENV RELEASE_VERSION ${RELEASE_VERSION}

ENV API_FULL_NAME ${API_NAME}-${RELEASE_VERSION}

ENV API_BUILD_DIR ${API_BUILD_DIR}

ENV APP_HOME_DIR ${APP_HOME_DIR}

ENV SPRING_PROFILES_ACTIVE ${SPRING_PROFILES_ACTIVE}

EXPOSE 8080 8081

USER root

RUN mkdir -p ${APP_HOME_DIR} \

    && groupadd -g 10000 appuser \

    && useradd --home-dir ${APP_HOME_DIR} -u 10000 -g appuser appuser

COPY . ${API_BUILD_DIR}

RUN cd ${API_BUILD_DIR}/ \

    && mvn clean package -Pjar -Dapi_name=${API_NAME} -Drelease_version=${RELEASE_VERSION} \

    && cp ${API_BUILD_DIR}/target/${API_FULL_NAME}.jar ${APP_HOME_DIR}/ \

    && cp ${API_BUILD_DIR}/files/entrypoint ${APP_HOME_DIR}/ \

    && echo "java -jar -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} ${APP_HOME_DIR}/${API_FULL_NAME}.jar" > ${APP_HOME_DIR}/run \

    && chmod -R 0766 ${APP_HOME_DIR} \

    && chown -R appuser:appuser ${APP_HOME_DIR} \

    && chmod g+w /etc/passwd

WORKDIR ${APP_HOME_DIR}

USER appuser

ENTRYPOINT [ "./entrypoint" ]

CMD ["./run"]
