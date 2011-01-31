package MusicBrainz::Server::Edit::Historic::AddArtist;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::Artist';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Add artist') }
sub edit_type { 17 }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Create' }

sub related_entities {
    my $self = shift;
    return {
        artist => [ $self->artist_id ]
    }
}

sub do_upgrade
{
    my $self = shift;
    return $self->upgrade_hash($self->new_value);
};

sub extra_parameters
{
    my $self = shift;
    return ( entity_id => $self->artist_id );
};

1;
