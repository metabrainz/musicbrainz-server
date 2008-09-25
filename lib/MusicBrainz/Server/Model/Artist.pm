package MusicBrainz::Server::Model::Artist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use Carp;
use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Artist;

=head2 load $id

Loads a new artist, given a specific GUID or database row id.

=cut

sub load
{
    my ($self, $id) = @_;
    
    my $artist = new MusicBrainz::Server::Artist($self->dbh);
    LoadEntity($artist, $id);

    return $artist;
}

sub find_similar_artists
{
    my ($self, $artist) = @_;

    croak "No artist was provided"
        unless ref $artist;

    my $similar_artists = $artist->GetRelations;

    return [ map {
        +{
            name   => $_->{name},
            mbid   => $_->{mbid},
            weight => $_->{weight},
        };
    } @$similar_artists ];
}

1;
