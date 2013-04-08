from fabric.api import *
from time import sleep
from fabric.colors import red
from datetime import date

env.use_ssh_config = True
env.sudo_prefix = "sudo -S -p '%(sudo_prompt)s' -H " % env

def prepare_release():
    """
    Prepare for a new release.
    """
    no_local_changes()
    local("git checkout beta")
    local("git pull --ff-only origin beta")
    local("git checkout master")
    local("git pull --ff-only origin master")
    local("git merge beta")
    local("git push origin master")

def socket_deploy():
    """
    Do a Unix FastCGI socket deployment of musicbrainz-server. This works by
    restarting the process and taking down the old one if a new process could
    successful be started.
    """
    with cd("~/musicbrainz-server"):
        run("git remote set-url origin git://github.com/metabrainz/musicbrainz-server.git")
        run("git pull --ff-only")
        run("~/musicbrainz-server/admin/socket-deploy.sh")

def no_local_changes():
    # The exit code of these will be 0 if there are no changes.
    # If there are changes, then the author should fix his damn code.
    with settings( hide("stdout") ):
        local("git diff --exit-code")
        local("git diff --exit-code --cached")

def beta():
    """
    Update the beta.musicbrainz.org server

    This requires you have a 'beta' alias in your .ssh/config file.
    """
    env.host_string = "beta"
    no_local_changes()

    with settings( hide("stdout", "stderr") ):
        local("git checkout beta")
        local("git merge master")
        local("git push origin beta")

    socket_deploy()

def test():
    """
    Update the test.musicbrainz.org server

    This requires you have a 'test' alias in your .ssh/config file.
    """
    env.host_string = "test"
    no_local_changes()

    with settings( hide("stdout", "stderr") ):
        local("git checkout test")
        local("git merge master")
        local("git push origin test")

    socket_deploy()

def production():
    """
    To upgrade the servers, first take them out of the load balancer one by
    one. Then, use Fabric to update them:

    fab production

    You will be prompted to check you wish to continue, and then prompted for a
    server to update. The Fabric deployment script will take care of taking the
    service down, running a Git pull (and running the rest of
    production-deploy.sh) and then bring the service back up.

    It will attempt to check that the server started correctly by looking at the
    tail of the log and also doing a curl against localhost.
    """
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

    with cd('/home/musicbrainz/musicbrainz-server'):
        # Carton has a tendency to change this file when it does update
        # It's important that we discard these
        sudo("git remote set-url origin git://github.com/metabrainz/musicbrainz-server.git", user="musicbrainz")
        sudo("git checkout -- carton.lock", user="musicbrainz")
        sudo("git reset HEAD -- carton.lock", user="musicbrainz")

        # If there's anything uncommited this must be fixed
        sudo("git diff --exit-code", user="musicbrainz")
        sudo("git diff --exit-code --cached", user="musicbrainz")

        old_rev = sudo("git rev-parse HEAD", user="musicbrainz")
        sudo("git pull --ff-only", user="musicbrainz")
        new_rev = sudo("git rev-parse HEAD", user="musicbrainz")

        sql_updates = sudo("git diff --name-only %s %s -- admin/sql/updates" % (old_rev, new_rev), user="musicbrainz")
        if sql_updates != '':
            puts("Remember to update the following files:")
            puts(sql_updates)

    shutdown()
    sudo("/home/musicbrainz/musicbrainz-server/admin/production-deploy.sh", user="musicbrainz")
    sudo("svc -u /etc/service/mb_server-fastcgi")

    puts("Waiting 20 seconds for server to start")
    sleep(20)

    sudo("/etc/init.d/nginx restart", pty=False)

    # A non-0 exit code from any of these will cause the deployment to abort
    with settings( hide("stdout") ):
        run("pgrep plackup")
        run("tail /etc/service/mb_server-fastcgi/log/main/current | grep started")
        run("wget http://localhost -O -")

def reset_test():
    """
    Reset the 'test' branch, and do a socket update release
    """
    no_local_changes()
    local("git checkout test")
    local("git reset --hard origin/beta")
    local("git push --force origin test")

    with settings(host_string='test'):
        with cd("/home/musicbrainz/musicbrainz-server"):
            run("git fetch")
            run("git reset --hard origin/test")
        socket_deploy()

def shutdown():
    sudo("svc -d /etc/service/mb_server-fastcgi")

def tag():
    tag = prompt("Tag name", default='v-' + date.today().strftime("%Y-%m-%d"))
    blog_url = prompt("Blog post URL", validate=r'^http.*')
    no_local_changes()
    local("git tag -u 'CE33CF04' %s -m '%s' master" % (tag, blog_url))
    local("git push origin %s" % (tag))
