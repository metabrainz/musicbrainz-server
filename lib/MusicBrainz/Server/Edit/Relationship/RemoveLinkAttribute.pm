package MusicBrainz::Server::Edit::Relationship::RemoveLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Str Int );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit';

sub edit_name { l('Remove relationship attribute') }
sub edit_type { $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE }

has '+data' => (
    isa => Dict[
        name        => Str,
        description => Str,
        id          => Int
    ]
);

no Moose;
__PACKAGE__->meta->make_immutable;
