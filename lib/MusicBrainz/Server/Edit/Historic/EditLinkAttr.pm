package MusicBrainz::Server::Edit::Historic::EditLinkAttr;
use Moose;

use MusicBrainz::Server::Data::Utils qw( remove_equal );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Edit relationship attribute') }
sub edit_type { 42 }
sub ngs_class { 'MusicBrainz::Server::Edit::Relationship::EditLinkAttribute' }

sub do_upgrade
{
    my $self = shift;

    my $old = {
        name        => $self->previous_value->{name},
        description => $self->previous_value->{description},
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
}

sub deserialize_previous_value
{
    my ($self, $value) = @_;

    my ($old_name, $old_description);
    if ($value =~ /\n/) {
        ($old_name, $old_description) = split /\n/, $value;
    }
    else {
        ($old_name, $old_description) = $value =~ /(.*) \((.*)\)?$/;
    }

    return {
        name => $old_name,
        descrption => $old_description
    }
}

1;
