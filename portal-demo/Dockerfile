FROM java:7-jre
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>


ENV PORTAL_USER portal
ENV PORTAL_HOME /opt/portal
ENV PORTAL_DISTRIBUTION demo-distribution-dev-4.2.2-SNAPSHOT
ENV PORTAL_CONF production
ENV PORTAL_HOST 0.0.0.0


# Netcat & locales
RUN apt-get update \
    && apt-get install -y netcat \
    && apt-get install -y locales \
    && locale-gen C.UTF-8 \
    && /usr/sbin/update-locale LANG=C.UTF-8 \
    && apt-get remove -y locales \
    && apt-get purge -y
ENV LANG C.UTF-8

# User
RUN useradd --create-home --home-dir /home/$PORTAL_USER --shell /bin/bash --user-group $PORTAL_USER


# Properties
COPY portal.properties /home/$PORTAL_USER/
COPY run.conf /home/$PORTAL_USER/
RUN chown $PORTAL_USER: /home/$PORTAL_USER/*


# Distribution
COPY $PORTAL_DISTRIBUTION.zip /tmp
RUN unzip -q -d /opt /tmp/$PORTAL_DISTRIBUTION.zip \
    && chmod -R 755 /opt/$PORTAL_DISTRIBUTION \
    && chown -R $PORTAL_USER: /opt/$PORTAL_DISTRIBUTION \
    && ln -s /opt/$PORTAL_DISTRIBUTION $PORTAL_HOME \
    && rm -f /tmp/$PORTAL_DISTRIBUTION.zip


# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


EXPOSE 8080

WORKDIR /opt/portal

