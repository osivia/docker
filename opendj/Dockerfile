FROM openjdk:7-jre
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8
ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV LDAP_PORT 1389
ENV ADMIN_CONNECTOR_PORT 5555


# Distribution
WORKDIR /opt
RUN wget -q https://github.com/ForgeRock/opendj-community-edition/releases/download/ce%2F2.6.4/OpenDJ-2.6.4.zip && unzip -q OpenDJ-2.6.4.zip && rm -f OpenDJ-2.6.4.zip
RUN chmod -R 755 opendj


# Configuration
RUN /opt/opendj/setup \
          --cli \
          --baseDN dc=ent-bretagne,dc=fr \
          --ldapPort ${LDAP_PORT} \
          --adminConnectorPort ${ADMIN_CONNECTOR_PORT} \
          --rootUserDN cn=Directory\ Manager \
          --rootUserPassword osivia \
          --no-prompt \
          --noPropertiesFile \
          --acceptLicense

COPY 99-user.ldif /opt/opendj/config/schema/

# Config spécifique passwords
RUN sed -i s\\^[#]*ds-cfg-allow-pre-encoded-passwords:.*$\\ds-cfg-allow-pre-encoded-passwords:true\\g /opt/opendj/config/config.ldif
RUN sed -i s\\^[#]*ds-cfg-single-structural-objectclass-behavior:.*$\\ds-cfg-single-structural-objectclass-behavior:accept\\g /opt/opendj/config/config.ldif

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

