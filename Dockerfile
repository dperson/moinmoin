FROM ubuntu:trusty
MAINTAINER David Personette <dperson@dperson.com>

# MoinMoin file info
ENV version 1.9.8
ENV sha256sum a74ba7fd8cf09b9e8415a4c45d7389ea910c09932da50359ea9796e3a30911a6

# Install uwsgi and MoinMoin
RUN TERM=dumb apt-get update -qq && \
    TERM=dumb apt-get install -qqy --no-install-recommends curl python \
                uwsgi uwsgi-plugin-python && \
    TERM=dumb apt-get clean && \
    curl -LOC- -s http://static.moinmo.in/files/moin-${version}.tar.gz && \
    sha256sum moin-${version}.tar.gz | grep -q "$sha256sum" && \
    mkdir moinmoin && \
    tar -xf moin-${version}.tar.gz -C moinmoin --strip-components=1 && \
    (cd moinmoin && \
    python setup.py install --force --prefix=/usr/local >/dev/null) && \
    rm -rf /var/lib/apt/lists/* /tmp/* moinmoin moin-${version}.tar.gz

# Configure
COPY docker.png /usr/local/lib/python2.7/dist-packages/MoinMoin/web/static/htdocs/common/
COPY moin.sh /usr/bin/
RUN sed -e '/logo_string/ { s/moinmoin/docker/; s/MoinMoin // }' \
                -e '/url_prefix_static/ {s/#\(url_prefix_static\)/\1/; s/my//}'\
                -e '/page_front_page.*Front/s/#\(page_front_page\)/\1/' \
                -e '/superuser/ { s/#\(superuser\)/\1/; s/YourName/mmAdmin/ }' \
                -e '/page_front_page/s/#u/u/' \
                /usr/local/share/moin/config/wikiconfig.py > \
                /usr/local/share/moin/wikiconfig.py && \
    chown -Rh www-data. /usr/local/share/moin/data \
                /usr/local/share/moin/underlay

VOLUME ["/usr/local/share/moin/data"]

EXPOSE 3031

ENTRYPOINT ["moin.sh"]
