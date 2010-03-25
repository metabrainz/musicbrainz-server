package MusicBrainz::Server::Edit::Historic::AddArtist;
use Moose;

use aliased 'MusicBrainz::Server::Entity::PartialDate';
use MusicBrainz::Server::Edit::Historic::Utils
    'upgrade_date', 'upgrade_id';

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::HashUpgrade' => {
    value_mapping => {
        type_id    => \&upgrade_id,
        begin_date => \&upgrade_date,
        end_date   => \&upgrade_date,
    },
    key_mapping => {
        ArtistName => 'name',
        SortName   => 'sort_name',
        Resolution => 'comment',
        Type       => 'type_id',
        BeginDate  => 'begin_date',
        EndDate    => 'end_date',
    }
};

sub edit_type { 17 }
sub edit_name { 'Add artist' }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Create' }

augment 'upgrade' => sub
{
    my $self = shift;
    return $self->upgrade_hash($self->new_value);
};

sub extra_parameters
{
    my $self = shift;
    return ( entity_id => $self->artist_id );
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
