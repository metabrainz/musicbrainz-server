package MusicBrainz::Server::Edit::Historic::RemoveArtist;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Delete' }
sub edit_type { 19 }
sub edit_name { 'Remove artist' }

sub do_upgrade {
    my $self = shift;
    return {
        entity_id => $self->row_id,
        name      => $self->previous_value
    }
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
