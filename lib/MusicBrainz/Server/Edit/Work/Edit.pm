package MusicBrainz::Server::Edit::Work::Edit;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Validation qw( normalise_strings );
use MusicBrainz::Server::Constants qw( $EDIT_WORK_EDIT );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
);
use MusicBrainz::Server::Translation qw( l ln );

use aliased 'MusicBrainz::Server::Entity::Work';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

sub edit_type { $EDIT_WORK_EDIT }
sub edit_name { l('Edit work') }
sub _edit_model { 'Work' }
sub work_id { shift->entity_id }

sub change_fields
{
    return Dict[
        name          => Optional[Str],
        comment       => Nullable[Str],
        type_id       => Nullable[Str],
        language_id   => Nullable[Int],
        iswc          => Nullable[Str]
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            name => Str
        ],
        new => change_fields(),
        old => change_fields()
    ],
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations,
        WorkType => 'type_id',
        Language => 'language_id',
    );

    $relations->{Work} = [ $self->entity_id ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name      => 'name',
        comment   => 'comment',
        type      => [ qw( type_id WorkType ) ],
        language  => [ qw( language_id Language ) ],
        iswc      => 'iswc',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{work} = $loaded->{Work}{ $self->entity_id }
        || Work->new( name => $self->data->{entity}{name} );

    return $data;
}

sub allow_auto_edit
{
    my $self = shift;

    my ($old_name, $new_name) = normalise_strings($self->data->{old}{name},
                                                  $self->data->{new}{name});
    return 0 if $old_name ne $new_name;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    return 0 if defined $self->data->{old}{type_id};
    return 0 if defined $self->data->{old}{iswc};

    return 1;
}

sub current_instance {
    my $self = shift;
    $self->c->model('Work')->get_by_id($self->entity_id),
}

sub _edit_hash {
    my ($self, $data) = @_;
    return $self->merge_changes;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
