[![logo](https://raw.githubusercontent.com/dperson/moinmoin/master/logo.png)](http://moinmo.in/)

# MoinMoin

Moinmoin wiki on uWSGI docker container

# What is MoinMoin?

MoinMoin is an advanced, easy to use and extensible WikiEngine with a large
community of users. Said in a few words, it is about collaboration on easily
editable web pages.

# How to use this image

## Hosting a simple wiki (still needs a web server in front of it)

    sudo docker run -it --name wiki -p 3031:3031 -d dperson/moinmoin

## Complex configuration

    sudo docker run -it --name wiki -d dperson/moinmoin
    sudo docker run -it --name web --link wiki:wiki -p 80:80 -p 443:443 -d \
                dperson/nginx -u "wiki:3031;/wiki"

A separate nginx site file for moinmoin is available from:
[moinmoin](https://raw.githubusercontent.com/dperson/moinmoin/master/moinmoin)

Default Admin user is set to 'mmAdmin'. To use, create a new user named
'mmAdmin' and set your desired password. Volums are used, to ease backups, etc.

## Configuration

    sudo docker run -it --rm dperson/moinmoin -h

    Usage: moin.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -p "</prefix>" Configure URI prefix for wiki, if you want other than
                    /wiki required arg: "</prefix>" - URI location
        -s "<super>" Configure superuser (admin ID) for the wiki
                    required arg: "<UserName>" - The user to manage the wiki
        -t ""       Configure timezone (defaults to EST5EDT)
                    possible arg: "[timezone]" - zoneinfo timezone for container

    The 'command' (if provided and valid) will be run instead of moinmoin

ENVIRONMENT VARIABLES (only available with `docker run`)

 * `PREFIX` - An above, set a URI where the app lives, IE `/wiki2`
 * `SUPER` - As above, set the super (admin) user for the wiki
 * `TZ` - As above, configure the zoneinfo timezone, IE `EST5EDT`
 * `USERID` - Set the UID for the app user
 * `GROUPID` - Set the GID for the app user

## Examples

Any of the commands can be run at creation with `docker run` or later with
`docker exec -it moin.sh` (as of version 1.3 of docker).

### Start moinmoin, and configure the timezone:

    sudo docker run -it -d dperson/moinmoin -t EST5EDT

OR using `environment variables`

    sudo docker run -it -e TZ=EST5EDT -d dperson/moinmoin

Will get you the same settings as

    sudo docker run -it --name wiki -d dperson/moinmoin
    sudo docker exec -it wiki moin.sh -t EST5EDT ls -AlF /etc/localtime
    sudo docker restart wiki

### Start moinmoin, and configure the prefix URI:

    sudo docker run -it -d dperson/moinmoin -p /otherwiki

OR

    sudo docker run -it -e PREFIX=/otherwiki -d dperson/moinmoin

### Start moinmoin, and configure the super (admin) user:

    sudo docker run -it -d dperson/moinmoin -s bob

OR

    sudo docker run -it -e SUPER=bob -d dperson/moinmoin

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/dperson/moinmoin/issues).