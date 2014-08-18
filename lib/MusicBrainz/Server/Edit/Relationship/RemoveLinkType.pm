package MusicBrainz::Server::Edit::Relationship::RemoveLinkType;
use Moose;
use MooseX::Types::Moose qw( Int Str ArrayRef Maybe );
use MooseX::Types::Structured qw( Dict  Optional Tuple );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Remove relationship type') }
sub edit_kind { 'remove' }
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
            max  => Maybe[Int], # this can be undef, for "no maximum"
            type => Optional[Int], # Used in NGS edits
        ]]
    ]
);

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
