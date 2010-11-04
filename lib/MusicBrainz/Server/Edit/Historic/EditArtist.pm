package MusicBrainz::Server::Edit::Historic::EditArtist;
use strict;
use warnings;

use MusicBrainz::Server::Data::Utils qw( remove_equal );

use base 'MusicBrainz::Server::Edit::Historic::Artist';

sub edit_type { 40 }
sub edit_name { 'Edit artist' }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Edit' }

sub do_upgrade
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
}

1;
