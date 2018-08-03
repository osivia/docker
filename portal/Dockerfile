FROM java:7-jre
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

ENV PORTAL_USER portal
ENV PORTAL_HOME /opt/portal
ENV PORTAL_DISTRIBUTION interactik-distribution-dev-1.0-SNAPSHOT
ENV PORTAL_CONF production
ENV PORTAL_HOST 0.0.0.0

# User
RUN useradd --create-home --home-dir /home/$PORTAL_USER --shell /bin/bash --user-group $PORTAL_USER

# Distribution
COPY interactik-distribution.zip /opt/
RUN cd /opt \
    && unzip -q interactik-distribution.zip \
    && chmod -R 755 /opt/${PORTAL_DISTRIBUTION} \
    && chown -R $PORTAL_USER: /opt/${PORTAL_DISTRIBUTION} \
    && ln -s /opt/${PORTAL_DISTRIBUTION} $PORTAL_HOME \
    && rm -f interactik-distribution.zip

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
