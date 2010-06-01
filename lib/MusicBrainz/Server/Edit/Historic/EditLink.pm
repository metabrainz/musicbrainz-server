package MusicBrainz::Server::Edit::Historic::EditLink;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Edit::Types qw( PartialDateHash );
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_date upgrade_type );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_LINK );
use MusicBrainz::Server::Data::Utils qw( remove_equal type_to_model );

use aliased 'MusicBrainz::Server::Entity::Link';
use aliased 'MusicBrainz::Server::Entity::LinkType';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Relationship';

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name     { 'Edit relationship' }
sub edit_type     { $EDIT_HISTORIC_EDIT_LINK }
sub historic_type { 34 }

sub change_fields
{
    return Dict[
        link_type_id     => Int,
        link_type_phrase => Str,
        entity0_id       => Int,
        entity0_name     => Str,
        entity0_type     => Str,
        entity1_name     => Str,
        entity1_id       => Int,
        entity1_type     => Str,
        begin_date       => PartialDateHash,
        end_date         => PartialDateHash,
        attributes       => ArrayRef[Int]
    ]
}

has '+data' => (
    isa => Dict[
        link_id => Int,
        old => change_fields(),
        new => change_fields(),
    ]
);

sub related_entities
{
    my $self = shift;

    my $old_type0 = $self->data->{old}->{entity0_type};
    my $old_type1 = $self->data->{old}->{entity1_type};
    my $new_type0 = $self->data->{new}->{entity0_type};
    my $new_type1 = $self->data->{new}->{entity1_type};

    my %rel;

    $rel{ $old_type0 } ||= []; push @{ $rel{ $old_type0} }, $self->data->{old}{entity0_id};
    $rel{ $old_type1 } ||= []; push @{ $rel{ $old_type1} }, $self->data->{old}{entity1_id};
    $rel{ $new_type0 } ||= []; push @{ $rel{ $new_type0} }, $self->data->{new}{entity0_id};
    $rel{ $new_type1 } ||= []; push @{ $rel{ $new_type1} }, $self->data->{new}{entity1_id};

    return \%rel;
}

sub _upgrade
{
    my ($self, $hash, $prefix) = @_;
    return {
        link_type_id     => $hash->{$prefix . 'linktypeid'},
        link_type_phrase => $hash->{$prefix . 'linktypephrase'},
        entity0_id       => $hash->{$prefix . 'entity0id'},
        entity0_name     => $hash->{$prefix . 'entity0name'},
        entity0_type     => upgrade_type($hash->{$prefix . 'entity0type'}),
        entity1_id       => $hash->{$prefix . 'entity1id'},
        entity1_name     => $hash->{$prefix . 'entity1name'},
        entity1_type     => upgrade_type($hash->{$prefix . 'entity1type'}),
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

    $fks{ $old_model0 } ||= []; push @{ $fks{ $old_model0} }, $self->data->{old}{entity0_id};
    $fks{ $old_model1 } ||= []; push @{ $fks{ $old_model1} }, $self->data->{old}{entity1_id};
    $fks{ $new_model0 } ||= []; push @{ $fks{ $new_model0} }, $self->data->{new}{entity0_id};
    $fks{ $new_model1 } ||= []; push @{ $fks{ $new_model1} }, $self->data->{new}{entity1_id};

    return \%fks;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $old_model0  = type_to_model($self->data->{old}->{entity0_type});
    my $old_model1  = type_to_model($self->data->{old}->{entity1_type});
    my $new_model0  = type_to_model($self->data->{new}->{entity0_type});
    my $new_model1  = type_to_model($self->data->{new}->{entity1_type});

    return {
        relationship => {
            old => Relationship->new(
                 entity0 => $loaded->{ $old_model0 }{ $self->data->{old}{entity0_id} } ||
                    $self->c->model($old_model0)->_entity_class->new( name => $self->data->{old}{entity0_name}),
                 entity1 => $loaded->{ $old_model1 }{ $self->data->{old}{entity1_id} } ||
                    $self->c->model($old_model0)->_entity_class->new( name => $self->data->{old}{entity1_name}),
                 link    => Link->new(
                     begin_date => PartialDate->new($self->data->{old}{begin_date}),
                     end_date   => PartialDate->new($self->data->{old}{end_date}),
                     type       => LinkType->new(
                         link_phrase => $self->data->{old}{link_type_phrase},
                     )
                 ),
                 direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD
            ),
            new => Relationship->new(
                 entity0 => $loaded->{ $new_model0 }{ $self->data->{new}{entity0_id} } ||
                    $self->c->model($new_model0)->_entity_class->new( name => $self->data->{new}{entity0_name}),
                 entity1 => $loaded->{ $new_model1 }{ $self->data->{new}{entity1_id} } ||
                    $self->c->model($new_model0)->_entity_class->new( name => $self->data->{new}{entity1_name}),
                 link    => Link->new(
                     begin_date => PartialDate->new($self->data->{new}{begin_date}),
                     end_date   => PartialDate->new($self->data->{new}{end_date}),
                     type       => LinkType->new(
                         link_phrase => $self->data->{new}{link_type_phrase},
                     )
                 ),
                 direction => $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD
            ),
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

no Moose;
__PACKAGE__->meta->make_immutable;


