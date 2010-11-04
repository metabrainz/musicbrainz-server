package MusicBrainz::Server::Edit::Historic::AddLabel;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::Label';

sub edit_type { 54 }
sub edit_name { 'Add label' }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::Create' }

sub do_upgrade
{
    my $self = shift;
    return $self->upgrade_hash($self->new_value);
};

sub extra_parameters
{
    my $self = shift;
    return ( entity_id => $self->row_id );
};

1;
