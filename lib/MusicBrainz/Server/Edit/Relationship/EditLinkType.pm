package MusicBrainz::Server::Edit::Relationship::EditLinkType;
use Moose;
use Data::Compare;
use MooseX::Types::Moose qw( Int Str ArrayRef );
use MooseX::Types::Structured qw( Dict  Optional Tuple );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_EDIT_LINK_TYPE );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';

sub edit_name { l('Edit relationship type') }
sub edit_type { $EDIT_RELATIONSHIP_EDIT_LINK_TYPE }

sub change_fields
{
    return Dict[
        parent_id           => Nullable[Str],
        name                => Optional[Str],
        child_order         => Optional[Int],
        link_phrase         => Optional[Str],
        reverse_link_phrase => Optional[Str],
        short_link_phrase   => Optional[Str],
        description         => Nullable[Str],
        priority            => Optional[Int],
        attributes          => Optional[ArrayRef[Dict[
            name => Optional[Str], # Used in old historic edits
            min  => Nullable[Int],
            max  => Nullable[Int],
            type => Optional[Int], # Used in the new edits
        ]]]
    ]
}

has '+data' => (
    isa => Dict[
        link_id => Int,
        old     => change_fields(),
        new     => change_fields(),
        types   => Optional[Tuple[Str, Str]],
    ]
);

sub edit_conditions
{
    my $conditions = {
        duration      => 0,
        votes         => 0,
        expire_action => $EXPIRE_ACCEPT,
        auto_edit     => 1,
    };
    return {
        $QUALITY_LOW    => $conditions,
        $QUALITY_NORMAL => $conditions,
        $QUALITY_HIGH   => $conditions,
    };
}

sub foreign_keys {
    my $self = shift;
    return {
        LinkAttributeType => [
            grep { defined }
            map { $_->{type} }
                @{ $self->data->{old}{attributes} },
                @{ $self->data->{new}{attributes} }
            ]
    }
}

sub _build_attributes {
    my ($self, $list, $loaded) = @_;
    return [
        map {
            MusicBrainz::Server::Entity::LinkTypeAttribute->new(
                min => $_->{min},
                max => $_->{max},
                type => $loaded->{LinkAttributeType}{ $_->{type} } ||
                    MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => $_->{name}
                    )
                  )
          } @$list
    ]
}

sub build_display_data {
    my ($self, $loaded) = @_;
    my ($old, $new) = (
        $self->data->{old}{attributes},
        $self->data->{new}{attributes}
    );
    return if Compare($old, $new);

    return {
        attributes => {
            old => $self->_build_attributes($old, $loaded),
            new => $self->_build_attributes($new, $loaded),
        }
    }
}

sub allow_auto_edit { 1 }

sub accept {
    my $self = shift;
    $self->c->model('LinkType')->update($self->data->{link_id}, $self->data->{new});
}

__PACKAGE__->meta->make_immutable;
no Moose;

