package MusicBrainz::Server::Edit::Release::EditReleaseLabel;
use Moose;

use Moose::Util::TypeConstraints qw( find_type_constraint subtype as );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDITRELEASELABEL );
use MusicBrainz::Server::Edit::Types qw( Nullable );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Edit Release Label' }
sub edit_type { $EDIT_RELEASE_EDITRELEASELABEL }

sub alter_edit_pending { { Release => [ shift->release_id ] } }
sub related_entities { { release => [ shift->release_id ] } }
sub models { [qw( Release )] }

subtype 'ReleaseLabelHash'
    => as Dict[
        label_id => Nullable[Int],
        catalog_number => Nullable[Str]
    ];

has '+data' => (
    isa => Dict[
        release_label_id => Int,
        release_id => Int,
        new => find_type_constraint('ReleaseLabelHash'),
        old => find_type_constraint('ReleaseLabelHash')
    ]
);

has 'release_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{release_id} }
);

has 'release' => (
    isa => 'Release',
    is => 'rw',
);

has 'release_label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{release_label_id} }
);

has 'release_label' => (
    isa => 'ReleaseLabel',
    is => 'rw',
);

sub initialize
{
    my ($self, %opts) = @_;
    my $release_label = delete $opts{release_label};
    die "You must specify the release label object to edit"
        unless defined $release_label;

    $self->data({
        release_label_id => $release_label->id,
        release_id => $release_label->release_id,
        $self->_change_data($release_label, keys %opts),
    });
};

sub accept
{
    my $self = shift;
    $self->c->model('ReleaseLabel')->update($self->release_label_id, $self->data->{new});
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
