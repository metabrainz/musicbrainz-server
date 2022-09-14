package MusicBrainz::Server::Edit::Release::ReorderMediums;
use utf8;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Edit::Types qw( Nullable NullableOnPreview );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REORDER_MEDIUMS );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';

sub edit_name { N_l('Reorder mediums') }
sub edit_kind { 'other' }
sub edit_type { $EDIT_RELEASE_REORDER_MEDIUMS }
sub edit_template { 'ReorderMediums' }

with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

use aliased 'MusicBrainz::Server::Entity::Release';

sub release_id { shift->data->{release}{id} }

has '+data' => (
    isa => Dict[
        release => Dict[
            id => Int,
            name => Str
        ],
        medium_positions => ArrayRef[
            Dict[
                medium_id => NullableOnPreview[Int],
                old => Nullable[Int],
                new => Int,
            ]
        ],
    ]
);

sub alter_edit_pending
{
    my $self = shift;
    return {
        'Release' => [ $self->release_id ],
        'Medium' => [ map { $_->{medium_id} } @{$self->data->{medium_positions}} ]
    }
}

sub initialize {
    my ($self, %opts) = @_;
    my $release = delete $opts{release} or die 'Missing release argument';
    my $medium_positions = delete $opts{medium_positions} or die 'Missing new medium positions';

    unless ($release->all_mediums) {
        $self->c->model('Medium')->load_for_releases($release);
    }

    $self->data({
        release => {
            id => $release->id,
            name => $release->name,
        },
        medium_positions => $medium_positions
    });

    return $self;
}

sub foreign_keys {
    my $self = shift;

    my %fk = ( Release => { $self->data->{release}{id} => [ ] } );

    map {
        $fk{Medium}->{ $_->{medium_id} } = []
    } @{ $self->data->{medium_positions} };

    return \%fk;
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my %data;

    $data{mediums} = [
        map {
            my $entity = $loaded->{Medium}{ $_->{medium_id} };
            {
                old => $_->{old} ? $_->{old} : 'new',
                # For some reason older edits have old as int but new as string
                new => $_->{new} + 0,
                title => $entity ? $entity->name : ''
            }
        }
        sort { $a->{new} <=> $b->{new} }
        @{ $self->data->{medium_positions} } ];

    my $release = $loaded->{Release}{ $self->data->{release}{id} };

    if ($release) {
        $self->c->model('ArtistCredit')->load($release);
    }

    $data{release} = to_json_object(
        $release || Release->new( name => $self->data->{release}{name} )
    );


    return \%data;
}

sub accept {
    my ($self) = @_;

    my %medium_positions = map { $_->{medium_id} => $_->{new} }
        @{ $self->data->{medium_positions} };
    my $new_positions = [values %medium_positions];

    my $possible_conflicts =
        $self->c->sql->select_list_of_hashes(<<~'SQL', $self->release_id, $new_positions);
            SELECT id, position
            FROM medium
            WHERE release = ?
            AND position = any(?)
            SQL

    for my $row (@$possible_conflicts) {
        unless (exists $medium_positions{$row->{id}}) {
            MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
                'Can’t move a medium into position ' . $row->{position} . ', where one already exists.'
            );
        }
    }

    $self->c->model('Medium')->reorder(%medium_positions);
}

1;
