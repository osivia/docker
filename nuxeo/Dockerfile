FROM java:7-jre
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>

RUN apt-get update  \
 && apt-get install sudo

# Openoffice
RUN apt-get install -y netcat \
    && apt-get purge -y

RUN sudo apt-get install -y imagemagick 

RUN apt-get  install -y libreoffice 


RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8
ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Vars
ENV NUXEO_USER nuxeo
ENV NUXEO_HOME /opt/nuxeo
ENV NUXEO_DISTRIBUTION demo-nx-distrib-4.7.2

# User
RUN useradd --create-home --home-dir /home/$NUXEO_USER --shell /bin/bash --user-group $NUXEO_USER

# Distribution
RUN cd /opt && wget http://www.osivia.org/nexus/content/repositories/osivia-releases/org/osivia/demo/demo-nx-distrib/4.7.2/${NUXEO_DISTRIBUTION}.zip \
	&& unzip ${NUXEO_DISTRIBUTION}.zip  \
    && chmod -R 755 /opt/${NUXEO_DISTRIBUTION} \
    && chown -R $NUXEO_USER: /opt/${NUXEO_DISTRIBUTION} \
    && ln -s ${NUXEO_DISTRIBUTION} $NUXEO_HOME \
    && rm -f ${NUXEO_DISTRIBUTION}.zip


# Properties
COPY nuxeo.conf /home/$NUXEO_USER/
RUN chown $NUXEO_USER: /home/$NUXEO_USER/*

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nuxeoctl", "console"]


EXPOSE 8080

WORKDIR $NUXEO_HOME

