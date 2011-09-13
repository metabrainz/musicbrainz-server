package MusicBrainz::Server::Edit::Historic::RemoveLinkAttribute;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_LINK_ATTR );
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name     { l('Remove relationship attribute') }
sub edit_type     { $EDIT_HISTORIC_REMOVE_LINK_ATTR }
sub historic_type { 43 }
sub ngs_class     { 'MusicBrainz::Server::Edit::Relationship::RemoveLinkAttribute' }

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub do_upgrade
{
    my $self = shift;
    my $name = $self->new_value->{name};
    return {
        id          => $self->row_id,
        name        => $name,
        description => substr($self->previous_value, length($name) + 2, -1)
    };
}

sub deserialize_previous_value { my $self = shift;
                                 shift; }

1;
