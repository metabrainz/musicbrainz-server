package MusicBrainz::Server::Edit::Historic::RemoveLink;
use Moose;
use Switch;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );

use aliased 'MusicBrainz::Server::Entity::Relationship';
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_LINK );
use MusicBrainz::Server::Data::Utils qw( type_to_model );

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name     { 'Remove relationship (historic)' }
sub historic_type { 35 }
sub edit_type     { $EDIT_HISTORIC_REMOVE_LINK }

has '+data' => (
    isa => Dict[
        entity0_ids  => ArrayRef[Int],
        entity1_ids  => ArrayRef[Int],
        entity0_type => Str,
        entity1_type => Str,
        link_type_id => Int,
        link_id      => Int,
    ]
);

sub related_entities
{
    my $self = shift;
    my $related;

    for my $e (qw( entity0 entity1 )) {
        my $type = $self->data->{ $e . '_type' };
        $related->{$type} = $self->data->{ $e . '_ids' }
            unless $type eq 'url';
    }

    return $related;
}

sub foreign_keys
{
    my $self = shift;
    return {
        type_to_model($self->data->{entity0_type}) => $self->data->{entity0_ids},
        type_to_model($self->data->{entity1_type}) => $self->data->{entity1_ids},
        LinkType                                   => [ $self->data->{link_type_id} ],
        Link                                       => [ $self->data->{link_id} ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    use Devel::Dwarn;
    Dwarn $loaded;
    return {
        entity0 => [ map {
            $loaded->{ type_to_model($self->data->{entity0_type}) }->{ $_ }
        } @{ $self->data->{entity0_ids} } ],
        entity1 => [ map {
            $loaded->{ type_to_model($self->data->{entity1_type}) }->{ $_ }
        } @{ $self->data->{entity1_ids} } ],
        relationship => Relationship->new(
            link => $loaded->{Link}{ $self->data->{link_id} }
        )
    }
}

sub _id_mapper
{
    my ($self, $type, $id) = @_;
    if ($type eq 'album') {
        return $self->album_release_ids($id);
    }
    elsif ($type eq 'track') {
        return [ $self->resolve_recording_id($id) ];
    }
    else {
        return [ $id ];
    }
}

sub _type_mapper
{
    my ($self, $type) = @_;

    my %type_map = (
        track => 'recording',
        album => 'release',
    );

    return $type_map{$type} || $type;
}

sub upgrade
{
    my $self = shift;

    $self->data({
        entity0_ids => $self->_id_mapper($self->new_value->{entity0type},
                                         $self->new_value->{entity0id}),
        entity1_ids => $self->_id_mapper($self->new_value->{entity1type},
                                         $self->new_value->{entity1id}),
        entity0_type => $self->_type_mapper($self->new_value->{entity0type}),
        entity1_type => $self->_type_mapper($self->new_value->{entity1type}),
        link_type_id => $self->new_value->{linktypeid},
        link_id      => $self->new_value->{linkid},
    });

    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
