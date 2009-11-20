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

sub alter_edit_pending { { Medium => [ shift->medium_id ] } }
sub models { [qw( Medium )] }

has 'medium_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{medium} }
);

has 'medium' => (
    is => 'rw',
);

subtype 'MediumHash'
    => as Dict[
        position => Optional[Int],
        tracklist_id => Optional[Int],
        name => Optional[Str],
        format_id => Nullable[Int],
    ];

has '+data' => (
    isa => Dict[
        medium => Int,
        old => find_type_constraint('MediumHash'),
        new => find_type_constraint('MediumHash'),
    ]
);

sub initialize
{
    my ($self, %opts) = @_;
    my $medium = delete $opts{medium}
        or die 'You must specify the medium to edit';

    $self->medium($medium);
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
