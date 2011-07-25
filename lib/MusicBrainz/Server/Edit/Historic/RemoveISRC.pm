package MusicBrainz::Server::Edit::Historic::RemoveISRC;
use strict;
use warnings;
use namespace::autoclean;
use MusicBrainz::Server::Translation qw ( l ln );

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Remove ISRC') }
sub edit_type { 72 }
sub ngs_class { 'MusicBrainz::Server::Edit::Recording::RemoveISRC' }

sub _build_related_entities {
    my $self = shift;
    return {
        recording => [ $self->data->{recording}{id} ]
    }
}

sub do_upgrade {
    my $self = shift;

    return {
        isrc => {
            id => $self->row_id,
            isrc => $self->new_value->{ISRC}
        },
        recording => {
            id => $self->resolve_recording_id($self->new_value->{TrackId}),
            name => '[ removed ]',
        }
    };
}

1;
