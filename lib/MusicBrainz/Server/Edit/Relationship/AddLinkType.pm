package MusicBrainz::Server::Edit::Relationship::AddLinkType;
use Moose;
use MooseX::Types::Structured qw( Dict Tuple Optional );
use MooseX::Types::Moose qw( Int Str ArrayRef );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ADD_TYPE );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Add relationship type' }
sub edit_type { $EDIT_RELATIONSHIP_ADD_TYPE }

has '+data' => (
    isa => Dict[
        types               => Tuple[Str, Str],
        name                => Str,
        parent              => Str,
        gid                 => Str,
        link_phrase         => Str,
        short_link_phrase   => Optional[Str],
        reverse_link_phrase => Str,
        child_order         => Optional[Int],
        description         => Str,
        priority            => Optional[Int],
        attributes => ArrayRef[Dict[
            name => Str,
            min  => Int,
            max  => Int
        ]]
    ]
);

no Moose;
__PACKAGE__->meta->make_immutable;
