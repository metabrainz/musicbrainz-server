package MusicBrainz::Server::Edit::Historic::AddReleaseGroup;
use Moose;

use MusicBrainz::Server::Edit::Historic::Utils 'upgrade_id';

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::HashUpgrade' => {
    value_mapping => {
        type_id       => \&upgrade_id,
    },
    key_mapping => {
        Name       => 'name',
        Type       => 'type_id',
    }
};

sub edit_type { 66 }
sub edit_name { 'Add release group' }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Create' }

augment 'upgrade' => sub
{
    my $self = shift;
    my $artist_id = $self->new_value->{ArtistId};
    return {
        %{ $self->upgrade_hash($self->new_value) },
        artist_credit => [
            {
                artist => $artist_id,
                name   => $self->artist_name($artist_id)
            }
        ]
    };
};

sub extra_parameters
{
    my $self = shift;
    return ( entity_id => $self->row_id );
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
