package MusicBrainz::Server::Edit::Relationship::Reorder;
use List::MoreUtils qw( any );
use Moose;
use MooseX::Types::Moose qw( ArrayRef Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( NullableOnPreview );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIPS_REORDER );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit';

sub edit_name { N_l('Reorder relationships') }
sub edit_kind { 'other' }
sub edit_type { $EDIT_RELATIONSHIPS_REORDER }

with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Relationship';

has '+data' => (
    isa => Dict[
        link_type_id => Int,
        relationship_order => ArrayRef[
            Dict[
                relationship_id => NullableOnPreview[Int],
                old => Int,
                new => Int,
            ]
        ],
    ]
);

sub alter_edit_pending {
    my $self = shift;
    return {
        Relationship => [
            map { $_->{relationship_id} }
                @{ $self->data->{relationship_order} }
        ]
    }
}

sub initialize {
    my ($self, %opts) = @_;

    my $link_type_id = delete $opts{link_type_id}
        or die 'Missing link type';

    my $order = delete $opts{relationship_order}
        or die 'Missing relationship order';

    $self->data({
        link_type_id => $link_type_id,
        relationship_order => $order,
    });

    return $self;
}

sub foreign_keys {
    my $self = shift;

    my ($link_type, @relationships) = $self->_load_relationships;

    my $model0 = type_to_model($link_type->entity0_type);
    my $model1 = type_to_model($link_type->entity1_type);

    my $load = {
        LinkType => {
            $link_type->id => [],
        },
        Relationship => {
            map { $_->id => [] } @relationships
        }
    };

    my $load_model0 = $load->{$model0} = {};
    my $load_model1 = $load->{$model1} = {};

    for (@relationships) {
        $load_model0->{$_->entity0_id} = ['ArtistCredit'];
        $load_model1->{$_->entity1_id} = ['ArtistCredit'];
    }

    return $load;
}

sub build_display_data {
    my ($self, $loaded) = @_;

    return {
        relationships => [
            map +{
                old => $_->{old},
                new => $_->{new},
                relationship => $loaded->{Relationship}{ $_->{relationship_id} },
            },
            sort { $a->{new} <=> $b->{new} }
                @{ $self->data->{relationship_order} }
        ]
    };
}

sub accept {
    my $self = shift;

    my ($link_type, @relationships) = $self->_load_relationships;

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        "The relationships cannot be reordered because they no longer share the same link type."
    ) if any { $_->link->type_id != $link_type_id } @relationships;

    # FIXME this should perform a three way merge and check for conflicts

    $self->c->model('Relationship')->reorder(
        $link_type->entity0_type, $link_type->entity1_type,
        map {
            $_->{relationship_id} => $_->{new}
        } @{ $self->data->{relationship_order} }
    );
}

sub _load_relationships {
    my $self = shift;

    my $link_type_id = $self->data->{link_type_id};
    my $link_type = $self->c->model('LinkType')->get_by_id($link_type_id);

    my %order = %{ $self->data->{relationship_order} };
    my @ids = keys %order;

    my $relationships = $self->c->model('Relationship')->get_by_ids(
        $link_type->entity0_type, $link_type->entity1_type, @ids
    );

    my @relationships = values %$relationships;
    $self->c->model('Link')->load(@relationships);

    return $link_type, @relationships;
}

1;
