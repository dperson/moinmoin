# MoinMoin

Moinmoin wiki on uWSGI docker image

# What is MoinMoin?

MoinMoin is an advanced, easy to use and extensible WikiEngine with a large
community of users. Said in a few words, it is about collaboration on easily
editable web pages.

[moinmo.in](http://moinmo.in/)

![logo](http://moinmo.in/moin_static19/common/moinmoin.png)

# How to use this image

## Hosting a simple wiki (still needs a web server in front of it)

    sudo docker run --name wiki -p 3031:3031 -d dperson/moinmoin

## Complex configuration

    sudo docker run --name wiki -d dperson/moinmoin
    sudo docker run --name web --link wiki:wiki -p 80:80 -p 443:443 -d dperson/nginx

A nginx site file for moinmoin is available from:
[moinmoin](https://raw.githubusercontent.com/dperson/moinmoin/master/moinmoin)

Admin user is set to 'mmAdmin'. To use, create a new user named 'mmAdmin' and
set your desired password. Volums are used, to ease backups, etc.

If you wish to adapt the default configuration, use something like the following
to copy it from a running container:

    sudo docker cp wiki:/some/file/or/directory /some/path

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/dperson/moinmoin/issues).
