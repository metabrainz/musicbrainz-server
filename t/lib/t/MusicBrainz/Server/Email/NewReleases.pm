package t::MusicBrainz::Server::Email::NewReleases;
use Test::Routine;
use Test::LongString;
use Test::More;

use MusicBrainz::Server::Test;
use MusicBrainz::Server::Email;

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::ArtistCreditName';
use aliased 'MusicBrainz::Server::Entity::Editor';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleaseEvent';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Medium';
use aliased 'MusicBrainz::Server::Entity::MediumFormat';
use aliased 'MusicBrainz::Server::Email::NewReleases';

test all => sub {

    my $editor = Editor->new(
        id => 9999,
        name => 'acid2',
        email => 'acid2@musicbrainz.org'
        );

    my $vinyl_format = MediumFormat->new( name => 'Vinyl' );
    my @releases = (
        Release->new(
            gid => 'b475f6e0-c4fd-4b1e-a104-8ba9de02a471',
            name => 'Resistance',
            events => [
                ReleaseEvent->new(
                    date => PartialDate->new( year => 2010 ),
                )
            ],
            artist_credit => ArtistCredit->new(
                names => [
                    ArtistCreditName->new( name => 'Break' )]),
            mediums => [
                Medium->new( format => MediumFormat->new( name => 'CD' ))]),
        Release->new(
            gid => 'ab950dd7-4bff-409c-b406-2ab9af1739b0',
            name => 'Psycho',
            events => [
                ReleaseEvent->new(
                    date => PartialDate->new( year => 2010, month => 12 )
                ),
            ],
            artist_credit => ArtistCredit->new(
                names => [
                    ArtistCreditName->new( name => 'Phace' )]),
            mediums => [
                map { Medium->new( format => $vinyl_format ) } (1..4) ])
        );

    my $email = NewReleases->new(
        editor => $editor,
        releases => \@releases
        );

    ok((grep {"$_" eq 'Message-Id' } $email->extra_headers), 'Has a message-id header');

    contains_string($email->text, $_->name, 'Has release name: ' . $_->name)
        for @releases;

    contains_string($email->text, $_->artist_credit->name,
                    'Has release artist credit: ' . $_->name)
        for @releases;

    contains_string($email->text, $_->combined_format_name,
                    'Has release medium formats: ' . $_->name)
        for @releases;

    contains_string($email->text, $_->events->[0]->date->format,
                    'Has release date: ' . $_->name)
        for @releases;

    contains_string($email->text, sprintf("/release/%s", $_->gid),
                    'Has release link: ' . $_->name)
        for @releases;

};

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010-2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;

