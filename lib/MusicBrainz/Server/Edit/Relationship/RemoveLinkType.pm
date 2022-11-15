package MusicBrainz::Server::Edit::Relationship::RemoveLinkType;
use Moose;
use MooseX::Types::Moose qw( Int Str ArrayRef Maybe );
use MooseX::Types::Structured qw( Dict  Optional Tuple );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( l N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Remove relationship type') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE }
sub edit_template { 'RemoveRelationshipType' }

has '+data' => (
    isa => Dict[
        link_type_id        => Optional[Int], # Optional for historic edits
        types               => Tuple[Str, Str],
        name                => Str,
        link_phrase         => Str,
        reverse_link_phrase => Str,
        long_link_phrase   => Optional[Str],
        description         => Nullable[Str],
        attributes          => ArrayRef[Dict[
            name => Optional[Str], # Only used in historic edits
            min  => Int,
            max  => Maybe[Int], # this can be undef, for "no maximum"
            type => Optional[Int], # Used in NGS edits
        ]]
    ]
);

sub foreign_keys {
    my $self = shift;
    return {
        LinkAttributeType => [
            grep { defined }
            map { $_->{type} }
                @{ $self->data->{attributes} }
            ]
    }
}

sub accept {
    my $self = shift;

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This relationship type is currently in use'
    ) if $self->c->model('LinkType')->in_use($self->data->{link_type_id});

    $self->c->model('LinkType')->delete($self->data->{link_type_id});
}

sub build_display_data {
    my ($self, $loaded) = @_;

    return {
        attributes => $self->_build_attributes($self->data->{attributes}, $loaded),
        description => $self->data->{description},
        entity0_type => $self->data->{types}[0],
        entity1_type => $self->data->{types}[1],
        link_phrase => $self->data->{link_phrase},
        long_link_phrase => $self->data->{long_link_phrase},
        name => $self->data->{name},
        defined($self->data->{link_type_id}) ? (relationship_type => to_json_object(
            $loaded->{LinkType}{ $self->data->{link_type_id} } ||
            MusicBrainz::Server::Entity::LinkType->new( name => $self->data->{name} ))
        ) : (),
        reverse_link_phrase => $self->data->{reverse_link_phrase},
    }
}

sub _build_attributes {
    my ($self, $list, $loaded) = @_;
    return [
        map {
            to_json_object(MusicBrainz::Server::Entity::LinkTypeAttribute->new(
                min => $_->{min},
                max => $_->{max},
                type => $loaded->{LinkAttributeType}{ $_->{type} } ||
                    MusicBrainz::Server::Entity::LinkAttributeType->new(
                        name => ($_->{name} || l('[removed]'))
                    )
                  ))
          } @$list
    ]
}

before restore => sub {
    my ($self, $data) = @_;
    $data->{long_link_phrase} = delete $data->{short_link_phrase}
        if exists $data->{short_link_phrase};
};

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
