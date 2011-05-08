package MusicBrainz::Server::Edit::Historic::AddISRCs;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub related_entities {
    my $self = shift;
    return {
        recording => [
            map { $_->{recording_id} } @{ $self->data->{isrcs} }
        ]
    }
}

sub edit_name { l('Add ISRCs') }
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
            recording    => {
                id => $self->resolve_recording_id(
                    $self->new_value->{"TrackId$i"}
                ),
                name => '[removed]',
            }
        };
    }

    return {
        isrcs => \@isrcs
    }
}

1;
