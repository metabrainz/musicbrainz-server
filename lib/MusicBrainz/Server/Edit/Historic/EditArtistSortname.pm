package MusicBrainz::Server::Edit::Historic::EditArtistSortname;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Edit artist name') }
sub edit_type { 2 }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Edit' }

sub _build_related_entities {
    my $self = shift;
    return {
        artist => [ $self->artist_id ]
    }
}

sub do_upgrade
{
    my $self = shift;

    return {
        entity => {
            id => $self->artist_id,
            name => '[removed]',
        },
        old => {
            sort_name => $self->previous_value
        },
        new => {
            sort_name => $self->new_value
        }
    };
}

sub deserialize_previous_value {
    my ($self, $previous) = @_;
    return $previous;
}

sub deserialize_new_value {
    my ($self, $previous) = @_;
    return $previous;
}

1;
