package MusicBrainz::Server::Edit::Historic::AddArtist;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::Artist';

sub edit_type { 17 }
sub edit_name { 'Add artist' }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::Create' }

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
