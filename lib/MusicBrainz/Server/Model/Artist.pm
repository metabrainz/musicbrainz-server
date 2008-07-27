package MusicBrainz::Server::Model::Artist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use Carp;
use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Facade::Artist;

=head2 load $id

Loads a new artist, given a specific GUID or database row id.

=cut

sub load
{
    my ($self, $id) = @_;
    
    my $artist = new MusicBrainz::Server::Artist($self->dbh);
    LoadEntity($artist, $id);

    MusicBrainz::Server::Facade::Artist->new_from_artist($artist);
}

sub find_similar_artists
{
    my ($self, $artist) = @_;

    croak "No artist was provided"
        unless ref $artist;

    croak "Artist was not constructed via a database lookup"
        unless ref $artist->{_a};

    my $similar_artists = $artist->{_a}->GetRelations;

    return [ map {
        MusicBrainz::Server::Facade::Artist->new( {
            name   => $_->{name},
            mbid   => $_->{mbid},
            weight => $_->{weight},
        } );
    } @$similar_artists ];
}

1;
