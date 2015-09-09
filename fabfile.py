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
            run("make attributes.pot instruments.pot instrument_descriptions.pot relationships.pot statistics.pot languages.pot languages_notrim.pot scripts.pot countries.pot")
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

    # Build and install translations
    sudo("su musicbrainz -c 'cd ~/musicbrainz-server && make -C po all_quiet && make -C po deploy'")

    production()

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

    sudo("su root -c 'cd /root/server-configs; git pull origin master'")
    sudo("su root -c 'cd /root/server-configs; git submodule update --init --recursive'")
    sudo('/root/server-configs/provision.sh')

    sudo("svc -h /etc/service/musicbrainz-server")
    sudo("svc -h /etc/service/musicbrainz-ws")

def tag():
    tag = prompt("Tag name", default='v-' + date.today().strftime("%Y-%m-%d"))
    blog_url = prompt("Blog post URL", validate=r'^http.*')
    no_local_changes()
    local("git tag -u 'CE33CF04' %s -m '%s' master" % (tag, blog_url))
    local("git push origin %s" % (tag))
