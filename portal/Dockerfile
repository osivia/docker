FROM openjdk:8-jdk
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>


RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        netcat \
        locales \
        vim \
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
#ENV PORTAL_VERSION=1.0.1
ENV PORTAL_VERSION=1.0-SNAPSHOT
ENV PORTAL_DISTRIBUTION_NAME=index-cloud-ens-portal-distribution
ENV PORTAL_DISTRIBUTION ${PORTAL_DISTRIBUTION_NAME}-${PORTAL_ENVIRONMENT}-${PORTAL_VERSION}
ENV PORTAL_DISTRIBUTION_ZIP ${PORTAL_DISTRIBUTION_NAME}-${PORTAL_VERSION}.zip
ENV PORTAL_CONF production
ENV PORTAL_HOST 0.0.0.0

# User
RUN useradd --create-home --home-dir /home/$PORTAL_USER --shell /bin/bash --user-group $PORTAL_USER

# Distribution
COPY ${PORTAL_DISTRIBUTION}.zip /opt/${PORTAL_DISTRIBUTION_ZIP}
RUN cd /opt \
#    && wget -q http://www.osivia.org/nexus/content/repositories/osivia-releases/fr/index/cloud/ens/portal/${PORTAL_DISTRIBUTION_NAME}/${PORTAL_VERSION}/${PORTAL_DISTRIBUTION_ZIP} \
    && unzip -q ${PORTAL_DISTRIBUTION_ZIP} \
    && chmod -R 755 /opt/${PORTAL_DISTRIBUTION} \
    && chown -R $PORTAL_USER: /opt/${PORTAL_DISTRIBUTION} \
    && ln -s /opt/${PORTAL_DISTRIBUTION} $PORTAL_HOME \
    && rm -f ${PORTAL_DISTRIBUTION_ZIP}


COPY jboss-log4j.xml /opt/${PORTAL_DISTRIBUTION}/jboss-as/server/production/conf
	
# Properties
COPY portal.properties /home/$PORTAL_USER/
COPY run.conf /home/$PORTAL_USER/
COPY cloud_fr.properties /home/$PORTAL_USER/
RUN chown $PORTAL_USER: /home/$PORTAL_USER/*

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


EXPOSE 8080

WORKDIR /opt/portal
