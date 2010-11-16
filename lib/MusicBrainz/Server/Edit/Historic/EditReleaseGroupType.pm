package MusicBrainz::Server::Edit::Historic::EditReleaseGroupType;
use Moose;

use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_id );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name { l('Edit release group type') }
sub edit_type { 70 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }

augment 'upgrade' => sub
{
    my $self = shift;
    return {
        entity_id => $self->row_id,
        old => {
            type_id => upgrade_id($self->previous_value)
        },
        new => {
            type_id => upgrade_id($self->new_value)
        }
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;

