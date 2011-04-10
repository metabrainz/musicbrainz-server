package MusicBrainz::Server::Edit::Relationship::AddLinkType;
use Moose;
use MooseX::Types::Moose qw( Int Str ArrayRef );
use MooseX::Types::Structured qw( Dict  Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ADD_TYPE );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';

sub edit_name { l('Add relationship type') }
sub edit_type { $EDIT_RELATIONSHIP_ADD_TYPE }

has '+data' => (
    isa => Dict[
        entity0_type        => Str,
        entity1_type        => Str,
        name                => Str,
        parent_id           => Str,
        gid                 => Nullable[Str],
        link_phrase         => Str,
        short_link_phrase   => Optional[Str],
        reverse_link_phrase => Str,
        child_order         => Optional[Int],
        description         => Nullable[Str],
        priority            => Optional[Int],
        attributes => ArrayRef[Dict[
            name => Optional[Str], # Used in old historic edits
            min  => Int,
            max  => Int,
            type => Optional[Int], # Used in the new edits
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
    $self->c->model('LinkType')->insert($self->data);
}

no Moose;
__PACKAGE__->meta->make_immutable;
