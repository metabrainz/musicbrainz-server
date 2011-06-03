package MusicBrainz::Server::Edit::Historic::AddTrackAnnotation;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Add track annotation') }
sub edit_type { 64 }
sub ngs_class { 'MusicBrainz::Server::Edit::Recording::AddAnnotation' }

sub related_entities {
    my $self = shift;
    return {
        recording => [ $self->data->{entity}{id} ]
    }
}

sub do_upgrade
{
    my ($self) = @_;

    return {
        text      => $self->new_value->{Text},
        changelog => $self->new_value->{ChangeLog},
        entity    => {
            id => $self->resolve_recording_id($self->row_id),
            name => '[removed]'
        },
        editor_id => $self->editor_id,
    }
}

sub extra_parameters
{
    my $self = shift;
    return (
        annotation_id => $self->resolve_annotation_id($self->id) || 0
    );
}

1;
