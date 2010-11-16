package MusicBrainz::Server::Edit::Historic::RemoveReleaseGroup;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Delete' }
sub edit_type { 68 }
sub edit_name { l('Remove release group') }

augment 'upgrade' => sub {
    my $self = shift;
    return {
        entity_id => $self->row_id,
        name      => $self->previous_value
    }
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;

