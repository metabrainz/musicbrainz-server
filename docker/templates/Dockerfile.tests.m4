m4_include(`server_base.m4')m4_dnl

install_javascript_and_templates()

install_translations()

RUN apt_install(`build-essential libexpat1 libexpat1-dev libxml2 libxml2-dev') && \
    cpanm TAP::Harness::JUnit && \
    apt_purge(`libexpat1-dev libxml2-dev')

RUN cd /tmp && \
    curl -sLO https://dl.google.com/linux/direct/CHROME_DEB && \
    apt_install(`./CHROME_DEB') && \
    rm CHROME_DEB && \
    cd -

RUN cd /tmp && \
    curl -sLO http://chromedriver.storage.googleapis.com/2.45/CHROME_DRIVER && \
    apt_install(`unzip') && \
    unzip CHROME_DRIVER -d /usr/local/bin && \
    rm CHROME_DRIVER && \
    cd -

RUN cd /home/musicbrainz && \
    git clone https://github.com/metabrainz/mmd-schema && \
    cd mmd-schema && \
    git reset --hard MMD_SCHEMA_TAG && \
    cd ../

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

copy_mb(`docker/musicbrainz-tests/DBDefs.pm lib/')

# Depends on DBDefs.pm.
RUN sudo_mb(`carton exec -- ./script/compile_resources.sh')

copy_mb(`docker/musicbrainz-tests/run_tests.sh docker/scripts/start_musicbrainz_server.sh /usr/local/bin/')
copy_mb(`flow-typed/ flow-typed/')
copy_mb(`script/ script/')
copy_mb(`t/ t/')
copy_mb(`.flowconfig .perlcriticrc ./')

ENTRYPOINT ["run_tests.sh"]
