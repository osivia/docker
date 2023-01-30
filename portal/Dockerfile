FROM openjdk:8-jdk
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>


RUN apt-get update \
    && apt-get install -y netcat locales vim \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

RUN localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8

ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV TOMCAT_ROOT /opt/portal/webapps/

ENV CATALINA_HOME /opt/portal
ENV PATH $CATALINA_HOME/bin:$PATH

ENV PORTAL_USER portal
ENV PORTAL_VERSION=1.0-SNAPSHOT
ENV PORTAL_ENVIRONMENT=dev
ENV PORTAL_DISTRIBUTION_NAME=elen-portail-distribution
ENV PORTAL_DISTRIBUTION ${PORTAL_DISTRIBUTION_NAME}-${PORTAL_ENVIRONMENT}-${PORTAL_VERSION}
ENV PORTAL_DISTRIBUTION_ZIP ${PORTAL_DISTRIBUTION_NAME}-${PORTAL_ENVIRONMENT}-${PORTAL_VERSION}.zip

# User
RUN useradd --create-home --home-dir /home/${PORTAL_USER} --shell /bin/bash --user-group ${PORTAL_USER}

# Distribution
COPY ${PORTAL_DISTRIBUTION_ZIP} /opt/
RUN cd /opt \
    && unzip -oq ${PORTAL_DISTRIBUTION_ZIP} \
    && chmod -R 755 /opt/${PORTAL_DISTRIBUTION} \
    && chown -R ${PORTAL_USER}: /opt/${PORTAL_DISTRIBUTION} \
    && ln -s /opt/${PORTAL_DISTRIBUTION} portal \
    && rm -f ${PORTAL_DISTRIBUTION_ZIP}

# Properties
COPY portal.properties /home/${PORTAL_USER}/
COPY configuration-ac-rennes.json /home/${PORTAL_USER}
COPY configuration-ac-nantes.json /home/${PORTAL_USER}
RUN chown ${PORTAL_USER}: /home/${PORTAL_USER}/*

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


EXPOSE 8080
EXPOSE 8787
