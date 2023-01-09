FROM openjdk:8-jdk
MAINTAINER Loïc Billon <loic.billon@roqu.io>

# Update
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        netcat \
	    perl \
	    locales \
	    pwgen \
	    imagemagick \
	    ffmpeg2theora \
	    ufraw \
	    poppler-utils \
	    libwpd-tools \
	    exiftool \
	    ghostscript \
	    libreoffice \
	    ffmpeg \
        x264 \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

# Locale
RUN localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8
ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Vars
ENV NUXEO_USER nuxeo
ENV NUXEO_HOME /opt/nuxeo
ENV NUXEO_VERSION=4.2.8-RC01-SNAPSHOT
ENV NUXEO_DISTRIBUTION toutatice-ecm-acrennes-greta-distribution-${NUXEO_VERSION}

# User
RUN useradd --create-home --home-dir /home/$NUXEO_USER --shell /bin/bash --user-group $NUXEO_USER

# Distribution
COPY ${NUXEO_DISTRIBUTION}.zip /opt/
RUN cd /opt \
#    && wget -q http://www.osivia.org/nexus/content/repositories/osivia-releases/fr/acrennes/greta/greta-nx-distrib/${NUXEO_VERSION}/${NUXEO_DISTRIBUTION}.zip  \
    && unzip -q ${NUXEO_DISTRIBUTION}.zip \
    && chmod -R 755 /opt/${NUXEO_DISTRIBUTION} \
    && chown -R $NUXEO_USER: /opt/${NUXEO_DISTRIBUTION} \
    && ln -s ${NUXEO_DISTRIBUTION} nuxeo \
    && rm -f ${NUXEO_DISTRIBUTION}.zip

# Properties
COPY nuxeo.conf /home/$NUXEO_USER/
RUN chown $NUXEO_USER: /home/$NUXEO_USER/*

COPY nxdata_20221010_000002.tgz /opt/nxdata.tgz

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


EXPOSE 8080
EXPOSE 8788

WORKDIR $NUXEO_HOME
