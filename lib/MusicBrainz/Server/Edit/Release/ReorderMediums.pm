package MusicBrainz::Server::Edit::Release::ReorderMediums;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict Map );

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REORDER_MEDIUMS );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Reorder mediums' }
sub edit_type { $EDIT_RELEASE_REORDER_MEDIUMS }

with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';

sub release_id { shift->data->{release}{id} }

# Medium order is a map of medium id to position
sub MediumOrder { Map[Int, Int] }

has '+data' => (
    isa => Dict[
        release => Dict[
            id => Int,
            name => Str
        ],
        old => MediumOrder,
        new => MediumOrder
    ]
);

sub initialize {
    my ($self, %opts) = @_;
    my $release = delete $opts{release} or die 'Missing release argument';
    my $new_order = delete $opts{new_order} or die 'Missing new medium order';

    unless ($release->all_mediums) {
        $self->c->model('Medium')->load_for_releases($release);
    }

    $self->data({
        release => {
            id => $release->id,
            name => $release->name
        },
        new => $new_order,
        old => {
            map {
                $_->id => $_->position
            } $release->all_mediums
        }
    });

    return $self;
}

sub foreign_keys {
    my $self = shift;

    my %fk = ( Release => { $self->data->{release}{id} => [ ] } );

    map {
        $fk{Medium}->{$_} = []
    } keys %{ $self->data->{old} };

    return \%fk;
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my %new = %{ $self->data->{new} };
    my %old = %{ $self->data->{old} };
    my %data;

    if ($self->preview)
    {
        my %old_swapped = map { $old{$_} => $_ } keys %old;

        $data{mediums} = [
            map {
                my $entity = $loaded->{Medium}{ $old_swapped{$_} };
                {
                    old => $old_swapped{$_} ? $_ : "new",
                    new => $new{$_},
                    title => $entity ? $entity->name : ""
                }
            }
            sort { $new{$a} <=> $new{$b} }
            keys %new ];
    }
    else
    {
        $data{mediums} = [
            map {
                my $entity = $loaded->{Medium}{ $_ };
                {
                    old => $old{$_},
                    new => $new{$_},
                    title => $entity ? $entity->name : ""
                }
            }
            sort { $new{$a} <=> $new{$b} }
            keys %new ];
    }

    $data{release} = $loaded->{Release}{ $self->data->{release}{id} }
        || Release->new( name => $self->data->{release}{name} );

    return \%data;
}

sub accept {
    my ($self) = @_;
    $self->c->model('Medium')->reorder(%{ $self->data->{new} });
}

1;
