package MusicBrainz::Server::Edit::Label::Create;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use Moose::Util::TypeConstraints qw( subtype find_type_constraint );
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Label';

use aliased 'MusicBrainz::Server::Entity::Label';

sub edit_name { l('Add label') }
sub edit_type { $EDIT_LABEL_CREATE }
sub _create_model { 'Label' }
sub label_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name => Str,
        sort_name => Str,
        type_id => Nullable[Int],
        label_code => Nullable[Int],
        begin_date => Nullable[PartialDateHash],
        end_date => Nullable[PartialDateHash],
        country_id => Nullable[Int],
        comment => Nullable[Str],
        ipi_code   => Nullable[Str]
    ]
);

sub foreign_keys
{
    my $self = shift;

    return {
        Label     => [ $self->entity_id ],
        LabelType => [ $self->data->{type_id} ],
        Country   => [ $self->data->{country_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $data = {
        label      => $loaded->{Label}{ $self->entity_id }
            || Label->new( name => $self->data->{name} ),
        name       => $self->data->{name},
        sort_name  => $self->data->{sort_name},
        type       => defined($self->data->{type_id}) &&
                        $loaded->{LabelType}->{ $self->data->{type_id} },
        label_code => $self->data->{label_code},
        country    => defined($self->data->{country_id}) &&
                        $loaded->{Country}->{ $self->data->{country_id} },
        comment    => $self->data->{comment},
        ipi_code   => $self->data->{ipi_code},
        begin_date => partial_date_from_row($self->data->{begin_date}),
        end_date   => partial_date_from_row($self->data->{end_date}),
    };
}

after insert => sub {
    my ($self) = @_;
    my $editor = $self->c->model('Editor')->get_by_id($self->editor_id);

    $self->c->model('Editor')->load_preferences($editor);
    if ($editor->preferences->subscribe_to_created_labels) {
        $self->c->model('Label')->subscription->subscribe($editor->id, $self->entity_id);
    }
};


sub allow_auto_edit { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
