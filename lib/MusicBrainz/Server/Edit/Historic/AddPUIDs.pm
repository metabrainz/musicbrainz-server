package MusicBrainz::Server::Edit::Historic::AddPUIDs;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Add PUIDs') }
sub edit_type { 47 }
sub ngs_class { 'MusicBrainz::Server::Edit::Recording::AddPUIDs' }

sub related_entities {
    my $self = shift;
    return {
        recording => [
            map { $_->{recording_id} } @{ $self->data->{puids} }
        ]
    }
}

sub do_upgrade {
    my ($self) = @_;

    my @puids;
    for (my $i = 0; ; $i++) {
        my $puid = $self->new_value->{"PUID$i"} or last;

        push @puids, {
            puid         => $puid,
            recording    => {
                id => $self->resolve_recording_id($self->new_value->{"TrackId$i"}),
                name => '[deleted]'
            }
        };
    }

return {
        client_version => $self->new_value->{ClientVersion},
        puids          => \@puids
    }
}

1;
