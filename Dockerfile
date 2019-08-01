#
# ala-collectory is based on tomcat8 official image
# 
#
FROM tomcat:8.5-jre8-alpine

RUN mkdir -p /data \
    /data/ala-collectory/config \
    /data/ala-collectory/upload/tmp \
    /data/ala-collectory/taxa/data

ARG ARTIFACT_URL=https://nexus.ala.org.au/service/local/repositories/releases/content/au/org/ala/ala-collectory/1.6.1/ala-collectory-1.6.1.war
ARG WAR_NAME=collectory

RUN wget $ARTIFACT_URL -q -O /tmp/$WAR_NAME && \
    apk add --update tini && \
    mkdir -p $CATALINA_HOME/webapps/$WAR_NAME && \
    unzip /tmp/$WAR_NAME -d $CATALINA_HOME/webapps/$WAR_NAME && \
    rm /tmp/$WAR_NAME

ADD https://raw.githubusercontent.com/AtlasOfLivingAustralia/ala-install/master/ansible/roles/collectory/files/data/config/connection-profiles.json /data/ala-collectory/config/
ADD https://raw.githubusercontent.com/AtlasOfLivingAustralia/ala-install/master/ansible/roles/collectory/files/data/config/charts.json /data/ala-collectory/config/

# check what else should be copied
COPY ./data/ala-collectory/config/* /data/ala-collectory/config/

# Tomcat configs
COPY ./tomcat-conf/* /usr/local/tomcat/conf/	

EXPOSE 8080

# NON-ROOT
RUN addgroup -g 101 tomcat && \
    adduser -G tomcat -u 101 -S tomcat && \
    chown -R tomcat:tomcat /usr/local/tomcat && \
    chown -R tomcat:tomcat /data

USER tomcat

ENV CATALINA_OPTS '-Dgrails.env=production'

ENTRYPOINT ["tini", "--"]
CMD ["catalina.sh", "run"]
