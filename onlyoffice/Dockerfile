FROM onlyoffice/documentserver:5.5
LABEL maintainer="Loïc Billon <lbillon@osivia.com>"

RUN apt-get update && apt-get install -y locales vim \
	&& localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8 \
	&& apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*

ENV LANG fr_FR.utf8
RUN locale >> /etc/default/locale

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV OO_CONF /etc/onlyoffice/documentserver/
COPY local.json ${OO_CONF}

ENTRYPOINT ["/bin/sh" "-c" "/app/ds/run-document-server.sh"]


