package MusicBrainz::Server::Edit::Historic::AddArtistAnnotation;
use strict;
use warninsg;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_type { 30 }
sub edit_name { 'Add artist annotation' }
sub ngs_class { 'MusicBrainz::Server::Edit::Artist::AddAnnotation' }

sub do_upgrade
{
    my $self = shift;
    return {
        editor_id => $self->editor_id,
        text      => $self->new_value->{Text},
        changelog => $self->new_value->{ChangeLog},
        entity_id => $self->artist_id,
    }
};

sub extra_parameters
{
    my $self = shift;
    return (
        annotation_id => $self->resolve_annotation_id($self->id) || 0
    );
}

sub deserialize_previous_value {
    my ($self, $previous) = @_;
    return $previous;
}

sub deserialize_new_value {
    my ($self, $previous) = @_;
    return $previous;
}

1;
