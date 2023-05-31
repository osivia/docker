FROM openjdk:8-jdk
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>


RUN apt-get update \
    && apt-get install -y  --force-yes netcat locales vim \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8

ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV PORTAL_USER portal
ENV PORTAL_HOME /opt/portal
ENV PORTAL_ENVIRONMENT=dev
ENV PORTAL_VERSION=7.0-SNAPSHOT
#ENV PORTAL_VERSION=6.0.9
ENV PORTAL_ZIP toutatice-portail-distribution-${PORTAL_VERSION}-${PORTAL_ENVIRONMENT}.zip
ENV PORTAL_DISTRIBUTION toutatice-portail-distribution-${PORTAL_ENVIRONMENT}-${PORTAL_VERSION}
ENV PORTAL_CONF production
ENV PORTAL_HOST 0.0.0.0

# User
RUN useradd --create-home --home-dir /home/$PORTAL_USER --shell /bin/bash --user-group $PORTAL_USER

# Distribution
COPY ${PORTAL_ZIP} /opt/
RUN cd /opt \
#	&& wget -q  https://projet.toutatice.fr/nexus3/repository/toutatice-releases/toutatice-portail/acrennes/distribution/toutatice-portail-acrennes-distribution/${PORTAL_VERSION}/toutatice-portail-acrennes-distribution-${PORTAL_VERSION}.zip -O toutatice-portail-acrennes-distribution.zip \
    && unzip -q ${PORTAL_ZIP} \
    && chmod -R 755 /opt/${PORTAL_DISTRIBUTION} \
    && chown -R $PORTAL_USER: /opt/${PORTAL_DISTRIBUTION} \
    && ln -s /opt/${PORTAL_DISTRIBUTION} $PORTAL_HOME \
    && rm -f ${PORTAL_ZIP} 

# Properties
COPY portal.properties /home/$PORTAL_USER/
COPY run.conf /home/$PORTAL_USER/
#COPY environnement_portail.properties /opt/portal/custom/params/
RUN chown $PORTAL_USER: /home/$PORTAL_USER/*

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


EXPOSE 8080

WORKDIR /opt/portal
