FROM tomcat:7
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8
ENV LANG fr_FR.utf8

ENV CAS_HOME /root
ENV TOMCAT_ROOT /usr/local/tomcat/webapps/

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# Distribution
COPY cas.war $TOMCAT_ROOT
COPY cas-config.properties $CAS_HOME

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
