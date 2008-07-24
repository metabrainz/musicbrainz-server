package MusicBrainz::Server::Model::Artist;

use strict;
use warnings;

use base 'Catalyst::Model';

use Carp;
use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Facade::Artist;

sub ACCEPT_CONTEXT
{
    my ($self, $c, @args) = @_;

    bless { _dbh => $c->mb->{DBH} }, ref $self;
}

=head2 load $id

Loads a new artist, given a specific GUID or database row id.

=cut

sub load
{
    my ($self, $id) = @_;

    if (defined $id)
    {
        my $artist = new MusicBrainz::Server::Artist($self->{_dbh});

        if (MusicBrainz::Server::Validation::IsGUID($id))
        {
            $artist->SetMBId($id);
        }
        else
        {
            if (MusicBrainz::Server::Validation::IsNonNegInteger($id))
            {
                $artist->SetId($id);
            }
            else
            {
                croak "$id is not a valid MBID or database row ID"
            }
        }

        $artist->LoadFromId()
            or croak "Could not load artist with id $id";

        MusicBrainz::Server::Facade::Artist->new_from_artist($artist);
    }
    else
    {
        croak "Cannot load an artist without an id specified";
    }
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
