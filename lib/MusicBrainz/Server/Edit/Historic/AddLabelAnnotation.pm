package MusicBrainz::Server::Edit::Historic::AddLabelAnnotation;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Add label annotation') }
sub edit_type { 57 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::AddAnnotation' }

augment 'upgrade' => sub
{
    my $self = shift;
    return {
        editor_id => $self->editor_id,
        text      => $self->new_value->{Text},
        changelog => $self->new_value->{ChangeLog},
        entity_id => $self->row_id,
    }
};

sub extra_parameters
{
    my $self = shift;
    return (
        annotation_id => $self->resolve_annotation_id($self->id)
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;

