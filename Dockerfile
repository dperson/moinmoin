FROM debian:stretch
MAINTAINER David Personette <dperson@gmail.com>

# Install uwsgi and MoinMoin
RUN export DEBIAN_FRONTEND='noninteractive' && \
    export version='1.9.9' && \
    export patch='561b7a9c2bd91b61d26cd8a5f39aa36bf5c6159e' && \
    export url='https://bitbucket.org/thomaswaldmann/moin-1.9/commits' && \
    export sha256sum='4397d7760b7ae324d7914ffeb1a9eeb15e09933b61468072acd3' && \
    sed -i 's/stretch /sid /g' /etc/apt/sources.list && \
    apt update -qq && \
    apt install -qqy --no-install-recommends ca-certificates  curl procps \
                patch python python-markdown uwsgi uwsgi-plugin-python \
                $(apt -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    file="moin-${version}.tar.gz" && \
    echo "downloading $file ..." && \
    curl -LOSs http://static.moinmo.in/files/$file && \
    curl -LOSs "${url}/${patch}/raw" && \
    sha256sum $file | grep -q "$sha256sum" || \
    { echo "expected $sha256sum, got $(sha256sum $file)"; exit 13; } && \
    mkdir moinmoin && \
    tar -xf $file -C moinmoin --strip-components=1 && \
    (cd moinmoin && \
    patch -p1 < ../raw && \
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
    apt purge -qqy ca-certificates curl patch && \
    apt autoremove -qqy && apt clean -qqy && \
    rm -rf /tmp/* /var/lib/apt/lists/* $file moinmoin raw
COPY docker.png /usr/local/lib/python2.7/dist-packages/MoinMoin/web/static/htdocs/common/
COPY moin.sh /usr/bin/

VOLUME ["/usr/local/share/moin"]

EXPOSE 3031

ENTRYPOINT ["moin.sh"]
