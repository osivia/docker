FROM tomcat:7-jre8
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>

RUN apt-get update && apt-get install -y locales vim openssl \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8 \
	&& apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV TOMCAT_ROOT /usr/local/tomcat/webapps/

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# Distribution
#RUN cd ${TOMCAT_ROOT} && wget -q http://www.osivia.org/nexus/content/repositories/osivia-releases/fr/index/cloud/ens/sso/cas-server-webapp/4.9-RC2/cas-server-webapp-4.9-RC2.war -O cas.war
COPY cas.war /usr/local/tomcat/webapps/
RUN cd /usr/local/tomcat/webapps/ && wget -q http://www.osivia.org/nexus/content/repositories/osivia-releases/fr/index/cloud/ens/ext/index-cloud-ens-ext-ws/1.0-ALPHA-6/index-cloud-ens-ext-ws-1.0-ALPHA-6.war -O pronote-ws.war 
#COPY pronote-ws.war /usr/local/tomcat/webapps/
#RUN cd /usr/local/tomcat/webapps/ && wget -q http://www.osivia.org/nexus/content/repositories/osivia-releases/fr/index/cloud/ens/ext/index-cloud-ens-ext-viewer/1.0-ALPHA-6/index-cloud-ens-ext-viewer-1.0-ALPHA-6.war -O cloud-viewer.war 

RUN mkdir -p /etc/cas; mkdir /etc/viewer

COPY cas.properties /etc/cas
COPY ehcache-replicated.xml /etc/cas
COPY log4j2.xml /etc/cas

COPY server.xml $CATALINA_HOME/conf

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8000
EXPOSE 8080
