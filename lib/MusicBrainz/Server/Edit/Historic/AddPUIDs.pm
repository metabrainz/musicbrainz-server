package MusicBrainz::Server::Edit::Historic::AddPUIDs;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Add PUIDs') }
sub edit_type { 47 }
sub ngs_class { 'MusicBrainz::Server::Edit::Recording::AddPUIDs' }

augment 'upgrade' => sub {
    my ($self) = @_;

    my @puids;
    for (my $i = 0; ; $i++) {
        my $puid = $self->new_value->{"PUID$i"} or last;

        push @puids, {
            puid         => $puid,
            recording_id => $self->resolve_recording_id($self->new_value->{"TrackId$i"})
        };
    }

return {
        client_version => $self->new_value->{ClientVersion},
        puids          => \@puids
    }
};

no Moose;
__PACKAGE__->meta->make_immutable;
