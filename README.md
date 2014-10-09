MoinMoin - wiki
===============

Moinmoin wiki on uWSGI docker image

To setup your own instance run:

sudo docker run -p 3031:3031 --name wiki dperson/moinmoin

or better yet:

sudo docker run --name wiki -d dperson/moinmoin
sudo docker run --name web --link wiki:wiki -p 80:80 -p 443:443 -d dperson/nginx

A nginx site file for moinmoin is available from:
https://raw.githubusercontent.com/dperson/moinmoin/master/moinmoin

Admin user is set to 'mmAdmin'. To use, create a new user named 'mmAdmin' and
set your desired password. Volums are used, to ease backups, etc.
