package MusicBrainz::Server::Edit::Historic::AddISRCs;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Add ISRCs' }
sub edit_type { 71 }
sub ngs_class { 'MusicBrainz::Server::Edit::Recording::AddISRCs' }

sub do_upgrade {
    my $self = shift;
    my @isrcs;
    for (my $i = 0; ; $i++)
    {
        my $isrc = $self->new_value->{"ISRC$i"}
            or last;

        push @isrcs, {
            isrc         => $isrc,
            recording_id => $self->resolve_recording_id(
                $self->new_value->{"TrackId$i"}
            )
        };
    }

    return {
        isrcs => \@isrcs
    }
}

1;
