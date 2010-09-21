package MusicBrainz::Server::Edit::Historic::AddISRCs;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Add ISRCs' }
sub edit_type { 71 }
sub ngs_class { 'MusicBrainz::Server::Edit::Recording::AddISRCs' }

augment 'upgrade' => sub {
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
};

no Moose;
__PACKAGE__->meta->make_immutable;
