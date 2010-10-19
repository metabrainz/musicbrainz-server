package MusicBrainz::Server::Edit::Historic::EditArtistName;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name { l('Edit artist name') }
sub edit_type { 1 }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Edit' }

augment 'upgrade' => sub
{
    my $self = shift;

    return {
        entity_id => $self->artist_id,
        old => {
            name => $self->previous_value
        },
        new => {
            name => $self->new_value
        }
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
