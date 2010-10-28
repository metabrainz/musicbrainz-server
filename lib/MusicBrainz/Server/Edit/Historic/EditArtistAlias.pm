package MusicBrainz::Server::Edit::Historic::EditArtistAlias;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub ngs_class { 'MusicBrainz::Server::Edit::Artist::EditAlias' }
sub edit_type { 28 }
sub edit_name { 'Edit artist alias' }

sub do_upgrade {
    my $self = shift;
    return {
        alias_id  => $self->row_id,
        entity_id => $self->artist_id,
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
