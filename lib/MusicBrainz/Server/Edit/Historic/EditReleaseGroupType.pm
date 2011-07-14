package MusicBrainz::Server::Edit::Historic::EditReleaseGroupType;
use strict;
use warnings;

use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_id );
use MusicBrainz::Server::Translation qw ( l ln );

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Edit release group type') }
sub edit_type { 70 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Edit' }

sub _build_related_entities {
    my $self = shift;
    return {
        release_group => [ $self->data->{entity}{id} ]
    }
}

sub do_upgrade
{
    my $self = shift;
    return {
        entity => {
            id => $self->row_id,
            name => '[removed]'
        },
        old => {
            type_id => upgrade_id($self->previous_value)
        },
        new => {
            type_id => upgrade_id($self->new_value)
        }
    };
}

sub deserialize_previous_value {
    my ($self, $previous) = @_;
    return $previous;
}

sub deserialize_new_value {
    my ($self, $previous) = @_;
    return $previous;
}

1;
