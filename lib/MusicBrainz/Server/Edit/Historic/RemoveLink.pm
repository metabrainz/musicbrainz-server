package MusicBrainz::Server::Edit::Historic::RemoveLink;
use strict;
use warnings;

use Switch;

use aliased 'MusicBrainz::Server::Entity::Relationship';
use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_LINK );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_date );
use MusicBrainz::Server::Edit::Types qw( PartialDateHash );
use MusicBrainz::Server::Translation qw ( l ln );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { l('Remove relationship (historic)') }
sub historic_type { 35 }
sub edit_type     { $EDIT_HISTORIC_REMOVE_LINK }

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
        $self->model0 => $self->data->{entity0_ids},
        $self->model1 => $self->data->{entity1_ids},
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        relationships => $self->relationship_cartesian_product($self->data, $loaded)
    }
}

sub model0 { type_to_model(shift->data->{entity0_type}) } 
sub model1 { type_to_model(shift->data->{entity1_type}) } 

sub relationship_cartesian_product
{
    my ($self, $relationship, $loaded) = @_;

    my $model0 = $self->model0;
    my $model1 = $self->model1;

    return [
        map {
            my $entity0_id = $_;
            map {
                my $entity1_id = $_;
                Relationship->new(
                    entity0 => $loaded->{ $model0 }{ $entity0_id } ||
                        $self->c->model($model0)->_entity_class->new( name => $relationship->{entity0_name}),
                    entity1 => $loaded->{ $model1 }{ $entity1_id } ||
                        $self->c->model($model1)->_entity_class->new( name => $relationship->{entity1_name}),
                    link    => Link->new(
                        id => $relationship->{link_id},
                        begin_date => PartialDate->new($relationship->{begin_date}),
                        end_date   => PartialDate->new($relationship->{end_date}),
                        type       => LinkType->new(
                            id => $relationship->{link_type_id},
                            link_phrase => $relationship->{link_type_phrase},
                        )
                    ),
                    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD
                ),
            } @{ $relationship->{entity1_ids} },
        } @{ $relationship->{entity0_ids} }
    ]
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
        entity0_name => $self->new_value->{entity0name},
        entity1_name => $self->new_value->{entity1name},
        link_type_id => $self->new_value->{linktypeid},
        link_id      => $self->new_value->{linkid},
        link_type_phrase => $self->new_value->{linktypephrase},
        begin_date => upgrade_date($self->new_value->{begindate}),
        end_date => upgrade_date($self->new_value->{enddate}),
    });

    return $self;
}

1;
