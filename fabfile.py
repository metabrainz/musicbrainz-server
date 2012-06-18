from fabric.api import *

env.use_ssh_config = True
env.hosts = [ 'pancake' ]

def socket_deploy():
    run("~/musicbrainz-server/socket-deploy.sh")

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
