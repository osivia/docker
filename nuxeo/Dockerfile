FROM java:7-jre
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>





# Openoffice
RUN apt-get update \
    && apt-get install -y netcat \
    && apt-get purge -y

RUN apt-get install -y imagemagick 

RUN apt-get  install -y libreoffice 


RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8
ENV LANG fr_FR.utf8

# Vars
ENV NUXEO_USER nuxeo
ENV NUXEO_HOME /opt/nuxeo
ENV NUXEO_DISTRIBUTION ottc-collab-nx-distrib-4.4-SNAPSHOT

# User
RUN useradd --create-home --home-dir /home/$NUXEO_USER --shell /bin/bash --user-group $NUXEO_USER


# Properties
COPY nuxeo.conf /home/$NUXEO_USER/
RUN chown $NUXEO_USER: /home/$NUXEO_USER/*


# Distribution
COPY $NUXEO_DISTRIBUTION.zip /tmp
RUN unzip -q -d /opt /tmp/$NUXEO_DISTRIBUTION.zip \
    && chmod -R 755 /opt/$NUXEO_DISTRIBUTION \
    && chown -R $NUXEO_USER: /opt/$NUXEO_DISTRIBUTION \
    && ln -s $NUXEO_DISTRIBUTION $NUXEO_HOME \
    && rm -f /tmp/$NUXEO_DISTRIBUTION.zip


# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nuxeoctl", "console"]


EXPOSE 8080

WORKDIR $NUXEO_HOME

