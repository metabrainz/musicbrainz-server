package MusicBrainz::Server::Edit::Historic::EditArtistAlias;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name { l('Edit artist alias') }
sub edit_type { 28 }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::EditAlias' }

augment 'upgrade' => sub {
    my $self = shift;
    return {
        alias_id  => $self->row_id,
        entity_id => $self->artist_id,
        new => {
            name => $self->new_value,
        },
        old => {
            name => $self->previous_value,
        }
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
