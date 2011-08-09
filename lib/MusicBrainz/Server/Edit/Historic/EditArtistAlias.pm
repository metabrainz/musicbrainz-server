package MusicBrainz::Server::Edit::Historic::EditArtistAlias;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Edit artist alias') }
sub edit_type { 28 }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::EditAlias' }

sub _build_related_entities {
    my $self = shift;
    return {
        artist => [ $self->artist_id ]
    }
}

sub do_upgrade {
    my $self = shift;
    return {
        alias_id  => $self->row_id,
        entity => {
            id => $self->artist_id,
            name => '[removed]'
        },
        new => {
            name => $self->new_value,
        },
        old => {
            name => $self->previous_value,
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
