FROM java:7-jre
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

ENV OPENDJ_HOME /opt/opendj

COPY 90-portal.ldif $OPENDJ_HOME
# Import
COPY import.ldif $OPENDJ_HOME


# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]


EXPOSE ${LDAP_PORT}
#EXPOSE ${ADMIN_CONNECTOR_PORT}

WORKDIR /opt/opendj

