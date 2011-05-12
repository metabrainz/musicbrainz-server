package MusicBrainz::Server::Edit::Historic::RemovePUID;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_PUID );
use MusicBrainz::Server::Translation qw ( l ln );

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub ngs_class { 'MusicBrainz::Server::Edit::PUID::Delete' }
sub edit_name { l('Remove PUID') }
sub edit_type { 46 }

sub related_entities {
    my $self = shift;
    return {
        recording => [ $self->data->{recording_id} ]
    }
}

sub do_upgrade
{
    my $self = shift;

    my $sql = $self->migration->sql;

    my $puid_id = $sql->select_single_value(q{
        SELECT id FROM puid WHERE puid = ?
    }, $self->previous_value);

    my $recording_id = $self->resolve_recording_id(
        $self->new_value->{TrackId});

    my $recording_puid_id = $sql->select_single_value(q{
        SELECT id FROM recording_puid WHERE puid = ? AND recording = ?
    }, $puid_id, $recording_id);

    return {
        puid              => $self->previous_value,
        recording         => {
            id => $recording_id,
            name => '[removed]',
        },

        recording_puid_id => $recording_puid_id,
        puid_id           => $puid_id,
    };
};

sub deserialize_previous_value {
    my ($self, $value ) = @_;
    return $value;
}
1;
