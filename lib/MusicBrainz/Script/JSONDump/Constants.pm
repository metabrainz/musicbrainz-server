package MusicBrainz::Script::JSONDump::Constants;

use strict;
use warnings;

use aliased 'MusicBrainz::Server::WebService::WebServiceInc';
use base 'Exporter';
use MusicBrainz::Server::Constants qw( @RELATABLE_ENTITIES );
use Readonly;

our @EXPORT_OK = qw(
    %DUMPED_ENTITY_TYPES
);

my %inc_rels = (
    relations => [map { ($_ =~ s/_/-/gr) . '-rels' } @RELATABLE_ENTITIES],
);

Readonly our %DUMPED_ENTITY_TYPES => (
    area => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation tags genres moods )], %inc_rels),
    },
    artist => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation ratings tags genres moods )], %inc_rels),
    },
    event => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation ratings tags genres moods )], %inc_rels),
    },
    instrument => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation tags genres moods )], %inc_rels),
    },
    label => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation ratings tags genres moods )], %inc_rels),
    },
    place => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation tags genres moods )], %inc_rels),
    },
    recording => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation artists artist-credits isrcs ratings tags genres moods )], %inc_rels),
    },
    release => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation artists artist-credits discids isrcs labels media recording-level-rels recordings release-groups tags genres moods )], %inc_rels),
    },
    release_group => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation artists artist-credits ratings tags genres moods )], %inc_rels),
    },
    series => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation tags genres moods )], %inc_rels),
    },
    work => {
        inc => WebServiceInc->new(inc => [qw( aliases annotation ratings tags genres moods )], %inc_rels),
    },
);

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
