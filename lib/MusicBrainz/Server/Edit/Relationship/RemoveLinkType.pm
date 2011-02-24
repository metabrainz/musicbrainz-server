package MusicBrainz::Server::Edit::Relationship::RemoveLinkType;
use Moose;
use MooseX::Types::Moose qw( Int Str ArrayRef );
use MooseX::Types::Structured qw( Dict  Optional Tuple );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( l ln );

with 'MusicBrainz::Server::Edit::Relationship';
extends 'MusicBrainz::Server::Edit';

sub edit_name { l('Remove relationship type') }
sub edit_type { $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE }

has '+data' => (
    isa => Dict[
        link_type_id        => Optional[Int], # Optional for historic edits
        types               => Tuple[Str, Str],
        name                => Str,
        link_phrase         => Str,
        reverse_link_phrase => Str,
        short_link_phrase   => Optional[Str],
        description         => Nullable[Str],
        attributes          => ArrayRef[Dict[
            name => Optional[Str], # Only used in historic edits
            min  => Int,
            max  => Int,
            type => Optional[Int], # Used in NGS edits
        ]]
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

sub allow_auto_edit { 1 }

sub accept {
    my $self = shift;
    $self->c->model('LinkType')->delete($self->data->{link_type_id});
}

no Moose;
__PACKAGE__->meta->make_immutable;
