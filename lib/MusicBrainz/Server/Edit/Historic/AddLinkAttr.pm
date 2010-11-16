package MusicBrainz::Server::Edit::Historic::AddLinkAttr;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Add relationship attribute') }
sub edit_type { 41 }
sub ngs_class { 'MusicBrainz::Server::Edit::Relationship::AddLinkAttribute' }

augment 'upgrade' => sub
{
    my $self = shift;
    my $parent = $self->c->model('LinkAttributeType')->get_by_gid($self->new_value->{parent});

    return {
        name        => $self->new_value->{name},
        description => $self->new_value->{desc},
        child_order => $self->new_value->{childorder},
        parent_id   => $parent ? $parent->id : 0
    };
};

no Moose;
__PACKAGE__->meta->make_immutable;
