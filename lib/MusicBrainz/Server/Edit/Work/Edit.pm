package MusicBrainz::Server::Edit::Work::Edit;
use Moose;

use Clone qw( clone );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Validation qw( normalise_strings );
use MusicBrainz::Server::Constants qw( $EDIT_WORK_EDIT );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
);
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Work';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

sub edit_type { $EDIT_WORK_EDIT }
sub edit_name { N_l('Edit work') }
sub _edit_model { 'Work' }
sub work_id { shift->entity_id }

sub change_fields
{
    return Dict[
        name          => Optional[Str],
        comment       => Nullable[Str],
        type_id       => Nullable[Str],
        language_id   => Nullable[Int],
        iswc          => Nullable[Str]
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            name => Str
        ],
        new => change_fields(),
        old => change_fields()
    ],
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations,
        WorkType => 'type_id',
        Language => 'language_id',
    );

    $relations->{Work} = [ $self->entity_id ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name      => 'name',
        comment   => 'comment',
        type      => [ qw( type_id WorkType ) ],
        iswc      => 'iswc',
        language  => [ qw( language_id Language ) ],
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{work} = $loaded->{Work}{ $self->entity_id }
        || Work->new( name => $self->data->{entity}{name} );

    return $data;
}

sub allow_auto_edit
{
    my $self = shift;

    my ($old_name, $new_name) = normalise_strings($self->data->{old}{name},
                                                  $self->data->{new}{name});
    return 0 if $old_name ne $new_name;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    return 0 if defined $self->data->{old}{type_id};

    return 0 if defined $self->data->{old}{language_id};

    return 1;
}

sub current_instance {
    my $self = shift;
    $self->c->model('Work')->get_by_id($self->entity_id),
}

around new_data => sub {
    my $orig = shift;
    my $self = shift;
    my $d = clone($self->$orig);
    delete $d->{iswc};
    return $d;
};

sub _edit_hash {
    my ($self, $data) = @_;
    my $d = $self->merge_changes;
    delete $d->{iswc};
    return $d;
};

after accept => sub {
    my $self = shift;

    if (exists $self->data->{new}{iswc}) {
        my @iswcs = $self->c->model('ISWC')->find_by_works($self->work_id);

        # This adds a new ISWC
        if (!$self->data->{old}{iswc} && @iswcs == 0) {
            $self->c->model('ISWC')->insert({ work_id => $self->work_id,
                                              iswc => $self->data->{new}{iswc} });
        }
        elsif (@iswcs == 1 && ($self->data->{old}{iswc} // '') eq $iswcs[0]->iswc){
            $self->c->model('ISWC')->delete($iswcs[0]->id);
            if (my $iswc = $self->data->{new}{iswc}) {
                $self->c->model('ISWC')->insert({ work_id => $self->work_id,
                                                  iswc => $iswc });
            }
        }
        else {
            MusicBrainz::Server::Edit::Exceptions::FailedDependency
                  ->throw('Data has changed since this edit was created, and now conflicts ' .
                              'with changes made in this edit.');
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
