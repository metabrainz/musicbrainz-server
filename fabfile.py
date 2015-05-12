from fabric.api import *
from time import sleep
from fabric.colors import red
from datetime import date
import re

env.use_ssh_config = True
env.sudo_prefix = "sudo -S -p '%(sudo_prompt)s' -H " % env

def translations():
    """
    Update translations
    """
    with lcd("po/"):
        local("./update_translations.sh")
        diff = local('git diff', capture=True)
        if not re.match('^\s*$', diff, re.MULTILINE):
            print diff
            local("git add *.po")
            commit_message = prompt("Commit message", default='Update translations from transifex.')
            local("git commit -m '%s'" % (commit_message))

def pot():
    """
    Update .pot files
    """
    env.host_string = "beta"
    with lcd("po/"):
        with cd("~/musicbrainz-server/po"):
            run("touch extract_pot_db")
            run("eval $(perl -Mlocal::lib) && make attributes.pot instruments.pot instrument_descriptions.pot relationships.pot statistics.pot languages.pot languages_notrim.pot scripts.pot countries.pot")
            get("~/musicbrainz-server/po/*.pot", "./%(path)s")
            run("git checkout HEAD *.pot")
        stats_diff = local("git diff statistics.pot", capture=True)
        local("touch extract_pot_templates")
        local("make mb_server.pot statistics.pot")
        stats_diff = stats_diff + local("git diff statistics.pot", capture=True)

        if not re.match('^\s*$', stats_diff, re.MULTILINE):
            puts("Please ensure that statistics.pot is correct and then commit manually, since it depends on both the database and templates.")
        else:
            local("git add *.pot")
            commit_message = prompt("Commit message", default='Update pot files using current code and production database.')
            local("git commit -m '%s'" % (commit_message))

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
        run("git submodule init")
        run("git submodule update")
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
    To upgrade an individual server, run:

    fab -H host production

    The Fabric deployment script will pull the server-configs repository, do
    a Chef provision, send SIGHUP to the musicbrainz-server and
    musicbrainz-ws services, and wait 30 seconds for them to restart.

    It will attempt to check that the server started correctly by checking
    for "plackup" processes and also doing a wget against localhost.
    """

    sudo('git --git-dir=/root/server-configs/.git --work-tree=/root/server-configs pull origin master')
    sudo('git --git-dir=/root/server-configs/.git --work-tree=/root/server-configs submodule update --init --recursive')
    sudo('/root/server-configs/provision.sh')

    sudo("svc -h /etc/service/musicbrainz-server")
    sudo("svc -h /etc/service/musicbrainz-ws")
    puts("Waiting 30 seconds for workers to start")
    sleep(30)

    # A non-0 exit code from any of these will cause the deployment to abort
    with settings(hide("stdout")):
        run("pgrep -f plackup")
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

def tag():
    tag = prompt("Tag name", default='v-' + date.today().strftime("%Y-%m-%d"))
    blog_url = prompt("Blog post URL", validate=r'^http.*')
    no_local_changes()
    local("git tag -u 'CE33CF04' %s -m '%s' master" % (tag, blog_url))
    local("git push origin %s" % (tag))
