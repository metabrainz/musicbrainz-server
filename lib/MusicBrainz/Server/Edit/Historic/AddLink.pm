package MusicBrainz::Server::Edit::Historic::AddLink;
use strict;
use warnings;

use MusicBrainz::Server::Edit::Types qw( PartialDateHash );
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_date upgrade_type );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_LINK );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Translation qw ( l ln );

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Relationship';

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { l('Add relationship') }
sub edit_type     { $EDIT_HISTORIC_ADD_LINK }
sub edit_template { 'historic/add_relationship' }
sub historic_type { 33 }

sub type0 { shift->data->{entity0_type} }
sub type1 { shift->data->{entity1_type} }
sub model0 { type_to_model(shift->type0) }
sub model1 { type_to_model(shift->type1) }

sub related_entities
{
    my $self = shift;

    my $type0 = $self->type0;
    my $type1 = $self->type1;

    my %rel;
    $rel{$type0} ||= [];
    $rel{$type1} ||= [];

    push @{ $rel{$type0} }, @{ $self->data->{entity0_ids} };
    push @{ $rel{$type1} }, @{ $self->data->{entity1_ids} };

    return \%rel;
}

sub foreign_keys
{
    my $self = shift;

    my $model0 = $self->model0;
    my $model1 = $self->model1;

    my %fks;
    $fks{ $model0 } ||= []; push @{ $fks{ $model0} }, @{ $self->data->{entity0_ids} };
    $fks{ $model1 } ||= []; push @{ $fks{ $model1} }, @{ $self->data->{entity1_ids} };

    return \%fks;
}

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
                        $self->c->model($model0)->_entity_class->new( name => $relationship->{entity1_name}),
                    link    => Link->new(
                        id => $relationship->{link_id},
                        begin_date => PartialDate->new($relationship->{begin_date}),
                        end_date   => PartialDate->new($relationship->{end_date}),
                        type       => LinkType->new(
                            id => $relationship->{link_type_id},
                            link_phrase => $relationship->{link_type_phrase},
                            name => $relationship->{link_type_name},
                            reverse_link_phrase => $relationship->{reverse_link_type_phrase}
                        )
                    ),
                    direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD
                ),
            } @{ $relationship->{entity1_ids} },
        } @{ $relationship->{entity0_ids} }
    ]
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        relationships => $self->relationship_cartesian_product($self->data, $loaded),
    }
}

sub upgrade
{
    my $self = shift;
    
    my $entity0_type = upgrade_type($self->new_value->{entity0type});
    my $entity0_ids  =
        $entity0_type eq 'release'   ? $self->album_release_ids($self->new_value->{entity0id})        :
        $entity0_type eq 'recording' ? [ $self->resolve_recording_id($self->new_value->{entity0id}) ] :
                                       [ $self->new_value->{entity0id} ];
    
    my $entity1_type = upgrade_type($self->new_value->{entity1type});
    my $entity1_ids  =
        $entity1_type eq 'release'   ? $self->album_release_ids($self->new_value->{entity1id})        :
        $entity1_type eq 'recording' ? [ $self->resolve_recording_id($self->new_value->{entity1id}) ] :
                                       [ $self->new_value->{entity1id} ];

    $self->data({
        link_id          => $self->new_value->{linkid},
        link_type_id     => $self->new_value->{linktypeid},
        link_type_name   => $self->new_value->{linktypename},
        link_type_phrase => $self->new_value->{linktypephrase},
        reverse_link_type_phrase => $self->new_value->{rlinktypephrase},
        entity0_ids      => $entity0_ids,
        entity0_name     => $self->new_value->{entity0name},
        entity0_type     => $entity0_type,
        entity1_ids      => $entity1_ids,
        entity1_name     => $self->new_value->{entity1name},
        entity1_type     => $entity1_type,
        begin_date       => upgrade_date($self->new_value->{begindate}),
        end_date         => upgrade_date($self->new_value->{enddate}),
    });

    return $self;
}

1;
