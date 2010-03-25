package MusicBrainz::Server::Edit::Historic::EditArtistSortname;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_type { 2 }
sub edit_name { 'Edit artist name' }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Edit' }

augment 'upgrade' => sub
{
    my $self = shift;

    return {
        entity_id => $self->artist_id,
        old => {
            sort_name => $self->previous_value
        },
        new => {
            sort_name => $self->new_value
        }
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
