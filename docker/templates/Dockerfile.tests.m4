m4_include(`server_base.m4')m4_dnl

install_javascript_and_templates()

RUN apt_install(`build-essential libexpat1 libexpat1-dev libxml2 libxml2-dev') && \
    cpanm TAP::Harness::JUnit && \
    apt_purge(`libexpat1-dev libxml2-dev')

RUN cd /tmp && \
    curl -sLO https://dl.google.com/linux/direct/CHROME_DEB && \
    apt_install(`./CHROME_DEB') && \
    rm CHROME_DEB && \
    cd -

RUN cd /tmp && \
    curl -sLO http://chromedriver.storage.googleapis.com/2.36/CHROME_DRIVER && \
    apt_install(`unzip') && \
    unzip CHROME_DRIVER -d /usr/local/bin && \
    rm CHROME_DRIVER && \
    cd -

RUN cd /home/musicbrainz && \
    git clone https://github.com/metabrainz/mmd-schema

ENV MMDSCHEMA /home/musicbrainz/mmd-schema

copy_common_mbs_files

COPY \
    docker/musicbrainz-tests/chrome.service \
    /etc/service/chrome/run
COPY \
    docker/scripts/start_template_renderer.sh \
    /etc/service/template-renderer/run
COPY \
    docker/musicbrainz-tests/website.service \
    /etc/service/website/run
RUN chmod 755 \
        /etc/service/chrome/run \
        /etc/service/template-renderer/run \
        /etc/service/website/run

git_info

COPY docker/musicbrainz-tests/DBDefs.pm lib/

# Depends on DBDefs.pm.
RUN sudo_mb(`carton exec -- ./script/compile_resources.sh default web-tests')

COPY docker/musicbrainz-tests/run_tests.sh /usr/local/bin/
COPY flow-typed/ flow-typed/
COPY script/ script/
COPY t/ t/
COPY .flowconfig .perlcriticrc ./

RUN chown_mb(`MBS_ROOT')

ENTRYPOINT ["run_tests.sh"]
