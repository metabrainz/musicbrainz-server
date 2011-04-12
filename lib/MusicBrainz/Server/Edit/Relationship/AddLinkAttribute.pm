package MusicBrainz::Server::Edit::Relationship::AddLinkAttribute;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ADD_ATTRIBUTE );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Relationship';

sub edit_name { l('Add relationship attribute') }
sub edit_type { $EDIT_RELATIONSHIP_ADD_ATTRIBUTE }

has '+data' => (
    isa => Dict[
        name        => Str,
        parent_id   => Nullable[Int],
        description => Str,
        child_order => Str
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        LinkAttributeType => [ $self->data->{parent_id} ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        parent => $loaded->{LinkAttributeType}->{ $self->data->{parent_id} }
    }
}

sub accept {
    my $self = shift;
    $self->c->model('LinkAttributeType')->insert($self->data)
};

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

no Moose;
__PACKAGE__->meta->make_immutable;
