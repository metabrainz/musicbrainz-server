package MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

extends 'MusicBrainz::Server::Edit::Annotation::Edit';
with 'MusicBrainz::Server::Edit::ReleaseGroup';

sub edit_name { N_l('Add release group annotation') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_RELEASEGROUP_ADD_ANNOTATION }

sub models { [qw( ReleaseGroup )] }

sub _annotation_model { shift->c->model('ReleaseGroup')->annotation }

has 'release_group_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities';

has 'release_group' => (
    isa => 'ReleaseGroup',
    is => 'rw',
);

sub foreign_keys
{
    my $self = shift;
    return {
        ReleaseGroup => [ $self->release_group_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig();
    $data->{release_group} = $loaded->{ReleaseGroup}->{ $self->release_group_id }
        || ReleaseGroup->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
