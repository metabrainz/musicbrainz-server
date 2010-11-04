package MusicBrainz::Server::Edit::Historic::RemoveISRC;
use strict;
use warnings;
use namespace::autoclean;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Remove ISRC' }
sub edit_type { 72 }
sub ngs_class { 'MusicBrainz::Server::Edit::Recording::RemoveISRC' }

sub do_upgrade {
    my $self = shift;

    return {
        isrc => {
            id => $self->row_id,
            isrc => $self->new_value->{ISRC}
        },
        recording => {
            id => $self->resolve_recording_id($self->new_value->{TrackId}),
            name => '[ deleted ]',
        }
    };
}

1;
