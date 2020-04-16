FROM tomcat:8
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>

RUN apt-get update && apt-get install -y locales vim \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8 \
	&& apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV TOMCAT_ROOT /usr/local/tomcat/webapps

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME" && mkdir -p /home/tomcat
WORKDIR $CATALINA_HOME

# War
COPY ws-toutatice-content-store-1.0.0-SNAPSHOT.war ${TOMCAT_ROOT}/ws-toutatice-content-store.war
COPY content-store.properties /home/tomcat/content-store.properties
COPY ws-toutatice-content-store.xml /usr/local/tomcat/conf/Catalina/localhost/ws-toutatice-content-store.xml


# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


EXPOSE 8000
EXPOSE 8080
