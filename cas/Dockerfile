FROM tomcat:7
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>

RUN apt-get update && apt-get install -y locales vim \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8 \
	&& apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV CAS_CONFIG /appli/conf
ENV TOMCAT_ROOT /usr/local/tomcat/webapps/

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# Distribution
RUN cd ${TOMCAT_ROOT} && wget -q http://www.osivia.org/nexus/content/repositories/osivia-releases/fr/gouv/education/foad/cas-server-webapp/4.4.31.1/cas-server-webapp-4.4.31.1.war -O cas.war
#COPY cas.war ${TOMCAT_ROOT}

RUN mkdir -p /appli/conf

COPY cas.properties $CAS_CONFIG
COPY ehcache-replicated.xml $CAS_CONFIG
COPY log4j2.xml $CAS_CONFIG
COPY server.xml $CATALINA_HOME/conf

ENV SERVICES_PATH /appli/conf/services/
COPY http.json $SERVICES_PATH
COPY https.json $SERVICES_PATH

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


EXPOSE 8000
EXPOSE 8080
