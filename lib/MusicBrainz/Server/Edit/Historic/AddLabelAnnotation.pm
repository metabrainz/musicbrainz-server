package MusicBrainz::Server::Edit::Historic::AddLabelAnnotation;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Add label annotation') }
sub edit_type { 57 }
sub ngs_class { 'MusicBrainz::Server::Edit::Label::AddAnnotation' }

sub related_entities {
    my $self = shift;
    return {
        label => [ $self->row_id ]
    }
}

sub do_upgrade
{
    my $self = shift;
    return {
        editor_id => $self->editor_id,
        text      => $self->new_value->{Text},
        changelog => $self->new_value->{ChangeLog},
        entity    => {
            id   => $self->row_id,
            name => '[removed]',
        }
    }
};

sub extra_parameters
{
    my $self = shift;
    return (
        annotation_id => $self->resolve_annotation_id($self->id) || 0
    );
}

1;

