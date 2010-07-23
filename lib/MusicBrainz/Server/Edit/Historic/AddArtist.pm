package MusicBrainz::Server::Edit::Historic::AddArtist;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::Artist';

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
