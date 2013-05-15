package MusicBrainz::Server::Edit::Relationship::RemoveLinkType;
use Moose;
use MooseX::Types::Moose qw( Int Str ArrayRef );
use MooseX::Types::Structured qw( Dict  Optional Tuple );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';

sub edit_name { N_l('Remove relationship type') }
sub edit_type { $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE }

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

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This relationship type is currently in use'
    ) if $self->c->model('LinkType')->in_use($self->data->{link_type_id});

    $self->c->model('LinkType')->delete($self->data->{link_type_id});
}

before restore => sub {
    my ($self, $data) = @_;
    $data->{long_link_phrase} = delete $data->{short_link_phrase}
        if exists $data->{short_link_phrase};
};

no Moose;
__PACKAGE__->meta->make_immutable;
