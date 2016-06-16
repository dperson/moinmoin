FROM debian:jessie
MAINTAINER David Personette <dperson@gmail.com>

# Install uwsgi and MoinMoin
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export version='1.9.8' && \
    export sha256sum='a74ba7fd8cf09b9e8415a4c45d7389ea910c09932da50359ea97' && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends curl python uwsgi \
                uwsgi-plugin-python \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    echo "downloading moin-${version}.tar.gz" && \
    curl -LOC- -s http://static.moinmo.in/files/moin-${version}.tar.gz && \
    sha256sum moin-${version}.tar.gz | grep -q "$sha256sum" && \
    mkdir moinmoin && \
    tar -xf moin-${version}.tar.gz -C moinmoin --strip-components=1 && \
    (cd moinmoin && \
    python setup.py install --force --prefix=/usr/local >/dev/null) && \
    sed -e '/logo_string/ { s/moinmoin/docker/; s/MoinMoin // }' \
                -e '/url_prefix_static/ {s/#\(url_prefix_static\)/\1/; s/my//}'\
                -e '/page_front_page.*Front/s/#\(page_front_page\)/\1/' \
                -e '/superuser/ { s/#\(superuser\)/\1/; s/YourName/mmAdmin/ }' \
                -e '/page_front_page/s/#u/u/' \
                /usr/local/share/moin/config/wikiconfig.py \
                >/usr/local/share/moin/wikiconfig.py && \
    chown -Rh www-data. /usr/local/share/moin/data \
                /usr/local/share/moin/underlay && \
    apt-get purge -qqy curl && \
    apt-get autoremove -qqy && apt-get clean -qqy && \
    rm -rf /tmp/* /var/lib/apt/lists/* moinmoin moin-${version}.tar.gz
COPY docker.png /usr/local/lib/python2.7/dist-packages/MoinMoin/web/static/htdocs/common/
COPY moin.sh /usr/bin/

VOLUME ["/usr/local/share/moin"]

EXPOSE 3031

ENTRYPOINT ["moin.sh"]