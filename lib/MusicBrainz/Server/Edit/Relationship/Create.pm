package MusicBrainz::Server::Edit::Relationship::Create;
use Moose;

use MusicBrainz::Server::Edit::Types qw( PartialDateHash );

extends 'MusicBrainz::Server::Edit::Generic::Create';

use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_CREATE );
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row type_to_model );
use MusicBrainz::Server::Edit::Types qw( Nullable );

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::Relationship';

sub edit_type { $EDIT_RELATIONSHIP_CREATE }
sub edit_name { 'Add relationship' }
sub _create_model { 'Relationship' }

has '+data' => (
    isa => Dict[
        entity0      => Int,
        entity1      => Int,
        link_type_id => Int,
        attributes   => Nullable[ArrayRef[Int]],
        begin_date   => Nullable[PartialDateHash],
        end_date     => Nullable[PartialDateHash],
        type0        => Str,
        type1        => Str
    ]
);

sub foreign_keys
{
    my ($self) = @_;
    my %load = (
        LinkType                            => [ $self->data->{link_type_id} ],
        LinkAttributeType                   => $self->data->{attributes},
        type_to_model($self->data->{type0}) => [ $self->data->{entity0} ]
    );

    # Type 1 my be equal to type 0, so we need to be careful
    $load{ type_to_model($self->data->{type1}) } ||= [];
    push @{ $load{ type_to_model($self->data->{type1}) } }, $self->data->{entity1};

    return \%load;
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $model0 = type_to_model($self->data->{type0});
    my $model1 = type_to_model($self->data->{type1});

    return {
        relationship => Relationship->new(
            link => Link->new(
                type       => $loaded->{LinkType}{ $self->data->{link_type_id} },
                begin_date => partial_date_from_row( $self->data->{begin_date} ),
                end_date   => partial_date_from_row( $self->data->{end_date} ),
                attributes => [
                    map {
                        my $attr    = $loaded->{LinkAttributeType}{ $_ };
                        my $root_id = $self->c->model('LinkAttributeType')->find_root($attr->id);
                        $attr->root( $self->c->model('LinkAttributeType')->get_by_id($root_id) );
                        $attr;
                    } @{ $self->data->{attributes} }
                ]
            ),
            entity0 => $loaded->{$model0}{ $self->data->{entity0} },
            entity1 => $loaded->{$model1}{ $self->data->{entity1} },
        )
    }
}

sub related_entities
{
    my ($self) = @_;

    my $result;
    if ($self->data->{type0} eq $self->data->{type1}) {
        $result = {
            $self->data->{type0} => [ $self->data->{entity0},
                                      $self->data->{entity1} ]
        };
    }
    else {
        $result = {
            $self->data->{type0} => [ $self->data->{entity0} ],
            $self->data->{type1} => [ $self->data->{entity1} ]
        };
    }

    return $result;
}

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Relationship')->adjust_edit_pending(
        $self->data->{type0}, $self->data->{type1},
        $adjust, $self->entity_id);
}

sub insert
{
    my ($self) = @_;
    my $relationship = $self->c->model('Relationship')->insert(
        $self->data->{type0},
        $self->data->{type1}, {
            entity0_id   => $self->data->{entity0},
            entity1_id   => $self->data->{entity1},
            attributes   => $self->data->{attributes},
            link_type_id => $self->data->{link_type_id},
            begin_date   => $self->data->{begin_date},
            end_date     => $self->data->{end_date},
        });

    $self->entity_id($relationship->id);
    $self->entity($relationship);
}

sub accept
{
    my ($self) = @_;

    my $link_type = $self->c->model('LinkType')->get_by_id(
        $self->data->{link_type_id}
    );

    if ($self->c->model('CoverArt')->can_parse($link_type->name)) {
        my $url = $self->c->model('URL')->get_by_id(
            $self->data->{entity1}
        );

        $self->c->model('CoverArt')->cache_cover_art(
            $self->data->{entity0}, $link_type->name, $url->url
        );
    }
}

sub reject
{
    my $self = shift;
    $self->c->model('Relationship')->delete(
        $self->data->{type0},
        $self->data->{type1},
        $self->entity_id
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
