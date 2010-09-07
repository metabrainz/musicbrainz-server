package MusicBrainz::Server::Edit::Relationship::EditLinkType;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Tuple Dict Optional );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_EDIT_LINK_TYPE );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Edit relationship type' }
sub edit_type { $EDIT_RELATIONSHIP_EDIT_LINK_TYPE }

sub change_fields
{
    return Dict[
        parent              => Nullable[Str],
        name                => Optional[Str],
        child_order         => Optional[Int],
        link_phrase         => Optional[Str],
        reverse_link_phrase => Optional[Str],
        short_link_phrase   => Optional[Str],
        description         => Nullable[Str],
        attributes          => Optional[ArrayRef[Dict[
            name => Str,
            min  => Int,
            max  => Int,
        ]]]
    ]
}

has '+data' => (
    isa => Dict[
        link_id => Int,
        old     => change_fields(),
        new     => change_fields(),
        types   => Tuple[Str, Str],
    ]
);

__PACKAGE__->meta->make_immutable;
no Moose;

