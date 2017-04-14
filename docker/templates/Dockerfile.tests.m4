m4_include(`server_base.m4')m4_dnl

install_javascript_and_templates()

RUN apt_install(`libexpat1 libexpat1-dev libxml2 libxml2-dev') && \
    cpanm TAP::Harness::JUnit && \
    apt_purge(`libexpat1-dev libxml2-dev')

RUN cd /home/musicbrainz && \
    git clone https://github.com/metabrainz/mmd-schema

ENV MMDSCHEMA /home/musicbrainz/mmd-schema

copy_common_mbs_files

COPY docker/musicbrainz-tests/DBDefs.pm lib/

# Depends on DBDefs.pm.
RUN sudo_mb(`carton exec -- ./script/compile_resources.sh')

COPY docker/musicbrainz-tests/run_tests.sh /usr/local/bin/
COPY script/ script/
COPY t/ t/
COPY .perlcriticrc ./

RUN touch /etc/service/consul-template/down

ENTRYPOINT ["run_tests.sh"]
