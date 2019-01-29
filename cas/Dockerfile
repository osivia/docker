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

ENV CAS_HOME /root
ENV TOMCAT_ROOT /usr/local/tomcat/webapps/

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# Distribution
RUN cd ${TOMCAT_ROOT} \
    && wget -q http://www.osivia.org/nexus/content/repositories/osivia-releases/org/osivia/demo/cas/cas-server-webapp/4.7-RC1/cas-server-webapp-4.7-RC1.war -O cas.war
COPY cas-config.properties $CAS_HOME

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
