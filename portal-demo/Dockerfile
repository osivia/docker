FROM java:7-jre
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>


# Portal user
ENV PORTAL_USER portal
RUN useradd --create-home --home-dir /home/$PORTAL_USER --shell /bin/bash --user-group $PORTAL_USER


# Portal properties
ENV PORTAL_PROPERTIES_FILE /home/$PORTAL_USER/portal.properties
COPY portal.properties /home/portal/portal.properties
RUN chown portal: /home/portal/portal.properties


# Portal distribution
ENV PORTAL_DISTRIBUTION demo-distribution-dev-4.2.2-SNAPSHOT
ENV PORTAL_HOME /opt/portal/jboss-as
ENV PORTAL_CONF production
ENV PORTAL_HOST 0.0.0.0
WORKDIR /opt
COPY $PORTAL_DISTRIBUTION.zip .
RUN unzip $PORTAL_DISTRIBUTION.zip && rm -f $PORTAL_DISTRIBUTION.zip
RUN chmod -R 755 $PORTAL_DISTRIBUTION && chown -R portal: $PORTAL_DISTRIBUTION
RUN ln -s $PORTAL_DISTRIBUTION portal


# Logs
ENV PORTAL_LOG_DIR /var/log/portal
RUN mkdir -p $PORTAL_LOG_DIR && chown -R portal: $PORTAL_LOG_DIR


# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


EXPOSE 8080

USER portal
WORKDIR /opt/portal

