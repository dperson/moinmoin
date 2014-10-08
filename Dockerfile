FROM ubuntu:trusty
MAINTAINER David Personette <dperson@dperson.com>

# MoinMoin file info
ENV version 1.9.7
ENV sha256sum f4ba1b5c956bd96d2a61e27e68d297aa63d1afbc80d5740e139dcdf0affb4db5

# Install nginx and uwsgi
RUN apt-get update && \
    apt-get install -qqy --no-install-recommends curl python \
                uwsgi uwsgi-plugin-python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Instal MoinMoin
RUN curl --retry 5 -LOC- -s http://static.moinmo.in/files/moin-1.9.7.tar.gz && \
    sha256sum moin-$version.tar.gz | cut -d' ' -f1 | grep -q "$sha256sum" || \
                exit 1 && \
    mkdir moinmoin && \
    tar -xf moin-$version.tar.gz -C moinmoin --strip-components=1 && \
    (cd moinmoin && \
    python setup.py install --force --prefix=/usr/local >/dev/null) && \
    rm -r moinmoin moin-$version.tar.gz

# Configure
COPY docker.png /usr/local/lib/python2.7/dist-packages/MoinMoin/web/static/htdocs/common/
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

CMD uwsgi --uid www-data \
                -s /tmp/uwsgi.sock \
                --uwsgi-socket 0.0.0.0:3031 \
                --plugins python \
                --pidfile /tmp/uwsgi-moinmoin.pid \
                --chdir /usr/local/share/moin \
                --python-path /usr/local/share/moin \
                --wsgi-file server/moin.wsgi \
                --master \
                --processes 4 \
                --harakiri 30 \
                --die-on-term
