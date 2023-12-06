package MusicBrainz::Server::Edit::Label::Create;
use Moose;

use MooseX::Types::Moose qw( ArrayRef Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_CREATE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview',
     'MusicBrainz::Server::Edit::Label',
     'MusicBrainz::Server::Edit::Role::SubscribeOnCreation' => {
        editor_subscription_preference => sub {
            shift->subscribe_to_created_labels;
        },
     },
     'MusicBrainz::Server::Edit::Role::Insert',
     'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit',
     'MusicBrainz::Server::Edit::Role::CheckDuplicates',
     'MusicBrainz::Server::Edit::Role::DatePeriod';

use aliased 'MusicBrainz::Server::Entity::Label';
use aliased 'MusicBrainz::Server::Entity::Area';

sub edit_name { N_l('Add label') }
sub edit_type { $EDIT_LABEL_CREATE }
sub _create_model { 'Label' }
sub label_id { shift->entity_id }
sub edit_template { 'AddLabel' }

has '+data' => (
    isa => Dict[
        name         => Str,
        sort_name    => Optional[Str],
        type_id      => Nullable[Int],
        label_code   => Nullable[Int],
        begin_date   => Nullable[PartialDateHash],
        end_date     => Nullable[PartialDateHash],
        area_id      => Nullable[Int],
        comment      => Nullable[Str],
        ipi_codes    => Optional[ArrayRef[Str]],
        isni_codes    => Optional[ArrayRef[Str]],
        ended        => Optional[Bool],
    ],
);

before initialize => sub {
    my ($self, %opts) = @_;
    die 'You must specify ipi_codes' unless defined $opts{ipi_codes};
    die 'You must specify isni_codes' unless defined $opts{isni_codes};
};

sub foreign_keys
{
    my $self = shift;

    return {
        Label     => [ $self->entity_id ],
        LabelType => [ $self->data->{type_id} ],
        Area      => [ $self->data->{area_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    {
        label      => to_json_object(($self->entity_id &&
            $loaded->{Label}{ $self->entity_id }) ||
            Label->new( name => $self->data->{name} ),
        ),
        name       => $self->data->{name},
        sort_name  => $self->data->{sort_name} // '',
        type       => defined($self->data->{type_id}) &&
                        to_json_object($loaded->{LabelType}{ $self->data->{type_id} }),
        label_code => $self->data->{label_code},
        area       => defined($self->data->{area_id}) &&
                      to_json_object($loaded->{Area}{ $self->data->{area_id} } // Area->new()),
        comment    => $self->data->{comment} // '',
        ipi_codes  => $self->data->{ipi_codes},
        isni_codes => $self->data->{isni_codes},
        begin_date => to_json_object(MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{begin_date})),
        end_date   => to_json_object(MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{end_date})),
        ended      => boolean_to_json($self->data->{ended}),
    };
}

sub restore {
    my ($self, $data) = @_;

    $data->{area_id} = delete $data->{country_id}
        if exists $data->{country_id};

    $data->{ipi_codes} = [ delete $data->{ipi_code} // () ]
        if exists $data->{ipi_code};

    $self->data($data);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
