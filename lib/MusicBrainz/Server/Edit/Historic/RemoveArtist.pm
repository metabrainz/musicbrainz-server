package MusicBrainz::Server::Edit::Historic::RemoveArtist;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Delete' }
sub edit_type { 19 }
sub edit_name { l('Remove artist') }

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
