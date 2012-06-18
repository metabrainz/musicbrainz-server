from fabric.api import *
from time import sleep
from fabric.colors import red

env.use_ssh_config = True
env.sudo_prefix = "sudo -S -p '%(sudo_prompt)s' -H " % env

def socket_deploy():
    run("~/musicbrainz-server/admin/socket-deploy.sh")

def beta():
    env.host_string = "beta"

    # The exit code of these will be 0 if there are no changes.
    # If there are changes, then the author should fix his damn code.
    with settings( hide("stdout") ):
        local("git diff")
        local("git diff -c")

    with settings( hide("stdout", "stderr") ):
        local("git checkout beta")
        local("git merge master")
        local("git push origin beta")

    socket_deploy()

def test():
    env.host_string = "test"

    # The exit code of these will be 0 if there are no changes.
    # If there are changes, then the author should fix his damn code.
    with settings( hide("stdout") ):
        local("git diff")
        local("git diff -c")

    with settings( hide("stdout", "stderr") ):
        local("git checkout next")
        local("git merge master")
        local("git push origin next")

    socket_deploy()

def production():
    puts("Checking if the server is quiet (expecting no requests in 5 second window)")
    with settings( hide("stdout") ):
        t1 = run("tail /var/log/nginx/001-musicbrainz.access.log")
        sleep(5)
        t2 = run("tail /var/log/nginx/001-musicbrainz.access.log")

    if t1 != t2:
        puts(red("The server does NOT appear to be quiet!"))
        cont = prompt("Do you wish to proceed?", validate=r'^(yes|no)', default='no')
        if cont == 'no':
            abort('User does not wish to proceed')

    sudo("svc -d /etc/service/mb_server-fastcgi")
    sudo("/home/musicbrainz/musicbrainz-server/production-deploy.sh", user="musicbrainz")
    sudo("svc -u /etc/service/mb_server-fastcgi")

    puts("Waiting 20 seconds for server to start")
    sleep(20)

    # A non-0 exit code from any of these will cause the deployment to abort
    with settings( hide("stdout") ):
        run("pgrep plackup")
        run("tail /etc/service/mb_server-fastcgi/log/main/current | grep started")
        run("wget http://localhost -O -")
