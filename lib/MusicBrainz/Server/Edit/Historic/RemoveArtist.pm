package MusicBrainz::Server::Edit::Historic::RemoveArtist;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Delete' }
sub edit_type { 19 }
sub edit_name { l('Remove artist') }

sub related_entities {
    my $self = shift;
    return {
        artist => [ $self->row_id ]
    }
}

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
