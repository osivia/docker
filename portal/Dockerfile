FROM openjdk:8-jdk
MAINTAINER Loïc Billon <loic.billon@roqu.io>

RUN apt-get update \
    && apt-get install -y netcat locales vim \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8

ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV PORTAL_USER portal
ENV PORTAL_HOME /opt/portal
ENV PORTAL_ENVIRONMENT=prod
ENV PORTAL_VERSION=4.6-SNAPSHOT
ENV PORTAL_ZIP acrennes-sites-distribution
#ENV PORTAL_DISTRIBUTION acrennes-sites-distribution-${PORTAL_ENVIRONMENT}-${PORTAL_VERSION}
ENV PORTAL_DISTRIBUTION acrennes-sites-distribution-${PORTAL_ENVIRONMENT}-${PORTAL_VERSION}
ENV PORTAL_CONF production
ENV PORTAL_HOST 0.0.0.0

# User
RUN useradd --create-home --home-dir /home/$PORTAL_USER --shell /bin/bash --user-group $PORTAL_USER

# Distribution
COPY acrennes-sites-distribution.zip /opt/
RUN cd /opt \
#    && wget -q https://projet.toutatice.fr/nexus3/repository/toutatice-releases/fr/toutatice/acrennes/sites/acrennes-sites-distribution/${PORTAL_VERSION}/${PORTAL_ZIP}.zip  \
    && unzip -q ${PORTAL_ZIP}.zip \
    && chmod -R 755 /opt/${PORTAL_DISTRIBUTION} \
    && chown -R $PORTAL_USER: /opt/${PORTAL_DISTRIBUTION} \
    && ln -s /opt/${PORTAL_DISTRIBUTION} $PORTAL_HOME \
    && rm -f ${PORTAL_ZIP}.zip

# Properties
COPY portal.properties /home/$PORTAL_USER/
COPY run.conf /home/$PORTAL_USER/
RUN chown $PORTAL_USER: /home/$PORTAL_USER/*

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


EXPOSE 8080

WORKDIR /opt/portal
