FROM tomcat:9
LABEL maintainer="Loïc Billon <lbillon@osivia.com>"

RUN apt-get update && apt-get install -y locales vim \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8 \
	&& apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV TOMCAT_ROOT /usr/local/tomcat/

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME" && mkdir -p /home/tomcat
WORKDIR $CATALINA_HOME

# War back-end
COPY tribu-backend-controller-1.0-SNAPSHOT.war ${TOMCAT_ROOT}/webapps/tribu-backend-controller.war
COPY application.properties ${TOMCAT_ROOT}/config/application.properties
# Zip front end
COPY tribu-app.zip ${TOMCAT_ROOT}/webapps

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


EXPOSE 8000
EXPOSE 8080
