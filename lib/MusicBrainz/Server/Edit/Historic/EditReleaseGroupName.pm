package MusicBrainz::Server::Edit::Historic::EditReleaseGroupName;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name { l('Edit release group name') }
sub edit_type { 65 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }

augment 'upgrade' => sub
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
};

no Moose;
__PACKAGE__->meta->make_immutable;
