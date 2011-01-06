package MusicBrainz::Server::Edit::Relationship::RemoveLinkType;
use Moose;
use MooseX::Types::Structured qw( Dict Tuple );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Historic';
with 'MusicBrainz::Server::Edit::Relationship';

sub edit_name { l('Remove relationship type') }
sub edit_type { $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE }

has '+data' => (
    isa => Dict[
        types               => Tuple[Str, Str],
        name                => Str,
        link_phrase         => Str,
        reverse_link_phrase => Str,
        description         => Str,
        attributes          => ArrayRef[Dict[
            name => Str,
            min  => Int,
            max  => Int
        ]]
    ]
);

no Moose;
__PACKAGE__->meta->make_immutable;
