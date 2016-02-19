FROM java:7-jre
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>


ENV LDAP_PORT 389
ENV ADMIN_CONNECTOR_PORT 4444


# Distribution
WORKDIR /opt
COPY OpenDJ-3.0.0.zip .
RUN unzip OpenDJ-3.0.0.zip && rm -f OpenDJ-3.0.0.zip
RUN chmod -R 755 opendj


# Configuration
RUN /opt/opendj/setup \
          --cli \
          --backendType je \
          --baseDN dc=osivia,dc=org \
          --ldapPort ${LDAP_PORT} \
          --adminConnectorPort ${ADMIN_CONNECTOR_PORT} \
          --rootUserDN cn=Directory\ Manager \
          --rootUserPassword osivia \
          --no-prompt \
          --noPropertiesFile \
          --acceptLicense
COPY 90-portal.ldif /opt/opendj/config/schema/


# Import
COPY import.ldif /opt/
RUN /opt/opendj/bin/import-ldif --ldifFile /opt/import.ldif --backendID userRoot --rejectFile /opt/rejected-entries.log --skipFile /opt/skipped-entries.log --overwrite


# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


EXPOSE ${LDAP_PORT}
EXPOSE ${ADMIN_CONNECTOR_PORT}

WORKDIR /opt/opendj

