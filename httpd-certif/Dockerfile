FROM httpd:2.4
MAINTAINER Cédric Krommenhoek <ckrommenhoek@osivia.com>

RUN apt-get update && apt-get install -y locales openssl && rm -rf /var/lib/apt/lists/* \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8
ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY reverse-proxy.conf /usr/local/apache2/conf/extra/
COPY server.crt /etc/ssl
COPY server.key /etc/ssl

# Entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 443
