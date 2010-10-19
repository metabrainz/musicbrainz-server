package MusicBrainz::Server::Edit::Historic::RemoveISRC;
use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Remove ISRC') }
sub edit_type { 72 }
sub ngs_class { 'MusicBrainz::Server::Edit::Recording::RemoveISRC' }

augment 'upgrade' => sub {
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
};

__PACKAGE__->meta->make_immutable;
1;
