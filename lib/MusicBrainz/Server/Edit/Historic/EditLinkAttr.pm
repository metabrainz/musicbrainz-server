package MusicBrainz::Server::Edit::Historic::EditLinkAttr;
use Moose;
use MusicBrainz::Server::Data::Utils qw( remove_equal );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Edit relationship attribute' }
sub edit_type { 42 }
sub ngs_class { 'MusicBrainz::Server::Edit::Relationship::EditLinkAttribute' }

augment 'upgrade' => sub
{
    my $self = shift;
    my ($old_name, $old_description) = $self->previous_value =~ /(.*) \((.*)\)$/;

    my $old = {
        name        => $old_name,
        description => $old_description,
        child_order => $self->new_value->{old_childorder},
        parent_id   => $self->link_attribute_from_name($self->new_value->{old_parent}) || 0,
    };
    my $new = {
        name        => $self->new_value->{name},
        description => $self->new_value->{desc},
        child_order => $self->new_value->{childorder},
        parent_id   => $self->link_attribute_from_name($self->new_value->{parent}) || 0,
    };

    remove_equal($old, $new);

    return {
        entity_id => $self->row_id,
        old => $old,
        new => $new
    };
};

sub deserialize_previous_value { my $self = shift; shift; }

no Moose;
__PACKAGE__->meta->make_immutable;
