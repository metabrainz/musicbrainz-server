package MusicBrainz::Server::Edit::Historic::EditReleaseGroupName;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Edit release group name' }
sub edit_type { 65 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }

sub do_upgrade
{
    my ($self) = @_;

    return {
        entity_id => $self->row_id,
        old => {
            name => $self->previous_value,
        },
        new => {
            name => $self->new_value
        }
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
