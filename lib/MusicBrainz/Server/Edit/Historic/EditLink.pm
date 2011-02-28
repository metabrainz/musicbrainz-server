package MusicBrainz::Server::Edit::Historic::EditLink;
use strict;
use warnings;

use MusicBrainz::Server::Edit::Types qw( PartialDateHash );
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_date upgrade_type );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_LINK );
use MusicBrainz::Server::Data::Utils qw( remove_equal type_to_model );
use MusicBrainz::Server::Translation qw ( l ln );

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Relationship';

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { l('Edit relationship (historic)') }
sub edit_type     { $EDIT_HISTORIC_EDIT_LINK }
sub historic_type { 34 }
sub edit_template { 'historic/edit_relationship' }

sub related_entities
{
    my $self = shift;

    my $old_type0 = $self->data->{old}->{entity0_type};
    my $old_type1 = $self->data->{old}->{entity1_type};
    my $new_type0 = $self->data->{new}->{entity0_type};
    my $new_type1 = $self->data->{new}->{entity1_type};

    my %rel;

    $rel{ $old_type0 } ||= [];
    push @{ $rel{ $old_type0} }, @{ $self->data->{old}{entity0_ids} }
        unless $old_type0 eq 'url';

    $rel{ $old_type1 } ||= []; push @{ $rel{ $old_type1} }, @{ $self->data->{old}{entity1_ids} }
        unless $old_type1 eq 'url';

    $rel{ $new_type0 } ||= []; push @{ $rel{ $new_type0} }, @{ $self->data->{new}{entity0_ids} }
        unless $new_type0 eq 'url';

    $rel{ $new_type1 } ||= []; push @{ $rel{ $new_type1} }, @{ $self->data->{new}{entity1_ids} }
        unless $new_type1 eq 'url';

    return \%rel;
}

sub _upgrade
{
    my ($self, $hash, $prefix) = @_;

    my $entity0_type = upgrade_type($hash->{$prefix . 'entity0type'});
    my $entity0_ids  =
        $entity0_type eq 'release'   ? $self->album_release_ids($hash->{$prefix . 'entity0id'})        :
        $entity0_type eq 'recording' ? [ $self->resolve_recording_id($hash->{$prefix . 'entity0id'}) ] :
                                       [ $hash->{$prefix . 'entity0id'} ];

    my $entity1_type = upgrade_type($hash->{$prefix . 'entity1type'});
    my $entity1_ids  =
        $entity1_type eq 'release'   ? $self->album_release_ids($hash->{$prefix . 'entity1id'})        :
        $entity1_type eq 'recording' ? [ $self->resolve_recording_id($hash->{$prefix . 'entity1id'}) ] :
                                       [ $hash->{$prefix . 'entity1id'} ];

    return {
        link_type_id     => $hash->{$prefix . 'linktypeid'},
        link_type_phrase => $hash->{$prefix . 'linktypephrase'},
        entity0_ids      => $entity0_ids,
        entity0_name     => $hash->{$prefix . 'entity0name'},
        entity0_type     => $entity0_type,
        entity1_ids      => $entity1_ids,
        entity1_name     => $hash->{$prefix . 'entity1name'},
        entity1_type     => $entity1_type,
        begin_date       => upgrade_date($hash->{$prefix . 'begindate'}),
        end_date         => upgrade_date($hash->{$prefix . 'enddate'}),
        attributes       => [ split / /, ($hash->{$prefix . 'attrs'} || '') ]
    }
}

sub foreign_keys
{
    my $self = shift;

    my $old_model0  = type_to_model($self->data->{old}->{entity0_type});
    my $old_model1  = type_to_model($self->data->{old}->{entity1_type});
    my $new_model0  = type_to_model($self->data->{new}->{entity0_type});
    my $new_model1  = type_to_model($self->data->{new}->{entity1_type});

    my %fks = (
        LinkType => [ map { $self->data->{$_}{link_type_id} } qw( old new ) ],
    );

    $fks{ $old_model0 } ||= []; push @{ $fks{ $old_model0} }, @{ $self->data->{old}{entity0_ids} };
    $fks{ $old_model1 } ||= []; push @{ $fks{ $old_model1} }, @{ $self->data->{old}{entity1_ids} };
    $fks{ $new_model0 } ||= []; push @{ $fks{ $new_model0} }, @{ $self->data->{new}{entity0_ids} };
    $fks{ $new_model1 } ||= []; push @{ $fks{ $new_model1} }, @{ $self->data->{new}{entity1_ids} };

    return \%fks;
}

sub relationship_cartesian_product
{
    my ($self, $relationship, $loaded) = @_;

    my $model0 = type_to_model($relationship->{entity0_type});
    my $model1 = type_to_model($relationship->{entity1_type});

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
                        begin_date => PartialDate->new($relationship->{begin_date}),
                        end_date   => PartialDate->new($relationship->{end_date}),
                        type       => LinkType->new(
                            link_phrase => $relationship->{link_type_phrase},
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
        relationship => {
            old => $self->relationship_cartesian_product($self->data->{old}, $loaded),
            new => $self->relationship_cartesian_product($self->data->{new}, $loaded),
        }
    }
}

sub upgrade
{
    my $self = shift;

    my $data = {
        link_id => $self->new_value->{linkid},
        old     => $self->_upgrade($self->new_value, 'old'),
        new     => $self->_upgrade($self->new_value, 'new'),
    };

    $self->data($data);

    return $self;
}

1;
