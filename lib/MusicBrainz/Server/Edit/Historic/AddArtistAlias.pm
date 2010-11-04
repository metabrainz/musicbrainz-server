package MusicBrainz::Server::Edit::Historic::AddArtistAlias;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub ngs_class { 'MusicBrainz::Server::Edit::Artist::AddAlias' }
sub edit_type { 15 }
sub edit_name { 'Add artist alias' }

sub do_upgrade {
    my $self = shift;
    return {
        name      => $self->new_value,
        entity_id => $self->row_id
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
