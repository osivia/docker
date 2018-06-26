FROM java:7-jre
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>

# Openoffice
RUN apt-get update \
    && apt-get install -y netcat \
    && apt-get install -y imagemagick \
    && apt-get install -y libreoffice \
    && apt-get install -y locales \
    && apt-get purge -y


RUN rm -rf /var/lib/apt/lists/*
RUN localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8
ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Vars
ENV NUXEO_USER nuxeo
ENV NUXEO_HOME /opt/nuxeo
ENV NUXEO_DISTRIBUTION nuxeo-cap-6.0-tomcat

# User
RUN useradd --create-home --home-dir /home/$NUXEO_USER --shell /bin/bash --user-group $NUXEO_USER


# Properties
COPY nuxeo.conf /home/$NUXEO_USER/
RUN chown $NUXEO_USER: /home/$NUXEO_USER/*


# Distribution
COPY nuxeo-toutatice-4.6.5.tar.gz /opt/${NUXEO_DISTRIBUTION}.tar.gz
RUN cd /opt \
	&& tar zxf ${NUXEO_DISTRIBUTION}.tar.gz  \
    && chmod -R 755 /opt/${NUXEO_DISTRIBUTION} \
    && chown -R $NUXEO_USER: /opt/${NUXEO_DISTRIBUTION} \
    && ln -s ${NUXEO_DISTRIBUTION} $NUXEO_HOME \
    && rm -f ${NUXEO_DISTRIBUTION}.tar.gz


# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nuxeoctl", "console"]


EXPOSE 8080
EXPOSE 8788

WORKDIR $NUXEO_HOME

