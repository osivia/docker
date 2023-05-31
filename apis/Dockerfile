FROM tomcat:8-jdk8
LABEL maintainer="Loïc Billon <lbillon@osivia.com>"

RUN apt-get update && apt-get install -y locales vim \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8 \
	&& apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME" && mkdir -p /home/tomcat
WORKDIR $CATALINA_HOME

# War
RUN cd ${CATALINA_HOME}/webapps \
    && wget -q  https://repository-maven.forge.education.gouv.fr/repository/maven-releases-aca-rennes/fr%2Ftoutatice%2Fldap%2Fapi%2Ftoutatice-ldap-api%2F1.7.3%2Ftoutatice-ldap-api-1.7.3.war -O toutatice-ldap-api.war
COPY toutatice-ldap-api.xml ${CATALINA_HOME}/conf/Catalina/localhost/toutatice-ldap-api.xml

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8000
EXPOSE 8080

