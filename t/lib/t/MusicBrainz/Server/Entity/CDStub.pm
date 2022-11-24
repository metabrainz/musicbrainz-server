package t::MusicBrainz::Server::Entity::CDStub;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::CDStub;
use MusicBrainz::Server::Entity::CDStubTrack;

=head1 DESCRIPTION

This test checks whether CD stub data is stored and calculated correctly.

=cut

test 'CD stub classes have the expected attributes' => sub {
    my $cdstubtrack = MusicBrainz::Server::Entity::CDStubTrack->new();
    note('Check for CDStubTrack attributes');
    has_attribute_ok($cdstubtrack, $_) for qw(
        cdstub_id
        cdstub
        title
        artist
        sequence
        length
    );

    my $cdstub = MusicBrainz::Server::Entity::CDStub->new();
    note('Check for CDStub attributes');
    has_attribute_ok($cdstub, $_) for qw(
        artist
        barcode
        comment
        date_added
        discid
        last_modified
        leadout_offset
        lookup_count
        modify_count
        source
        title
        track_count
        track_offset
    );
};

test 'CD stub data is stored / calculated properly' => sub {
    my $cdstubtrack = MusicBrainz::Server::Entity::CDStubTrack->new();
    my $cdstub = MusicBrainz::Server::Entity::CDStub->new();

    note('We add basic data to track and CD stub');
    $cdstubtrack->title('Track title');
    $cdstub->title('CDStub Title');
    $cdstub->tracks([$cdstubtrack]);
    $cdstub->leadout_offset('100000');

    is(
        $cdstub->title,
        'CDStub Title',
        'The CD stub title is stored as expected',
    );

    is(
        $cdstub->tracks->[0]->title,
        'Track title',
        'The CD stub track title is stored as expected',
    );

    is(
        $cdstub->length,
        '1333333',
        'The CD stub length is calculated correctly',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
