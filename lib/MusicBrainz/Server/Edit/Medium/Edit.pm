package MusicBrainz::Server::Edit::Medium::Edit;
use Moose;

use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use Moose::Util::TypeConstraints qw( find_type_constraint subtype as );

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub edit_type { $EDIT_MEDIUM_EDIT }
sub edit_name { 'Edit Medium' }

sub alter_edit_pending { { Medium => [ shift->data->{medium_id} ] } }
sub related_entities { { release => [ shift->release_id ] } }
sub models { [qw( Medium )] }

subtype 'MediumHash'
    => as Dict[
        position => Optional[Int],
        name => Nullable[Str],
        format_id => Nullable[Int],
    ];

has '+data' => (
    isa => Dict[
        medium => Int,
        old => find_type_constraint('MediumHash'),
        new => find_type_constraint('MediumHash'),
    ]
);

has 'release_id' => (
    isa => 'Int',
    is => 'rw',
);

sub foreign_keys {
    my $self = shift;
    if (exists $self->data->{new}{format_id}) {
        return {
            MediumFormat => {
                $self->data->{new}{format_id} => [],
                $self->data->{old}{format_id} => [],
            }
        }
    }
    else {
        return { };
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $data = {};

    if (exists $self->data->{new}{format_id}) {
        $data->{format} = {
            new => $loaded->{MediumFormat}->{ $self->data->{new}{format_id} },
            old => $loaded->{MediumFormat}->{ $self->data->{old}{format_id} }
        };
    }

    for my $attribute (qw( name position )) {
        if (exists $self->data->{new}{$attribute}) {
            $data->{$attribute} = {
                new => $self->data->{new}{$attribute},
                old => $self->data->{old}{$attribute},
            };
        }
    }

    return $data;
}

sub initialize
{
    my ($self, %opts) = @_;
    my $medium = delete $opts{medium}
        or die 'You must specify the medium to edit';

    $self->release_id($medium->release_id);
    $self->data({
        medium => $medium->id,
        $self->_change_data($medium, %opts)
    });
}

override 'accept' => sub
{
    my ($self) = @_;
    my $medium_data = $self->c->model('Medium');
    $medium_data->update($self->medium_id, $self->data->{new});
};

__PACKAGE__->meta->make_immutable;
1;
