package MusicBrainz::Server::Edit::Historic::EditArtist;
use Moose;

use MusicBrainz::Server::Data::Utils qw( remove_equal );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';
with 'MusicBrainz::Server::Edit::Historic::Artist';

sub edit_name { l('Edit artist') }
sub edit_type { 40 }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Edit' }

augment 'upgrade' => sub
{
    my $self = shift;

    my $old = $self->upgrade_hash($self->previous_value);
    my $new = $self->upgrade_hash($self->new_value);

    remove_equal($old, $new);

    return {
        entity_id => $self->artist_id,
        old => $old,
        new => $new
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
1;
