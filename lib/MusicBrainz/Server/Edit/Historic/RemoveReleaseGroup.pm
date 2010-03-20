package MusicBrainz::Server::Edit::Historic::RemoveReleaseGroup;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic';

sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Delete' }
sub edit_type { 68 }
sub edit_name { 'Remove release group' }

augment 'upgrade' => sub {
    my $self = shift;
    return {
        entity_id => $self->row_id,
        name      => $self->previous_value
    }
};

sub deserialize_previous_value { 0 }
sub deserialize_new_value      { 0 }

no Moose;
__PACKAGE__->meta->make_immutable;
1;

