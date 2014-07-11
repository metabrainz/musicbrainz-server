package MusicBrainz::Server::Edit::Event::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_EDIT );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    date_closure
    merge_partial_date
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Validation qw( normalise_strings );

use JSON::Any;

use MooseX::Types::Moose qw( ArrayRef Bool Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Event';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Event';

sub edit_name { N_l('Edit event') }
sub edit_type { $EDIT_EVENT_EDIT }

sub _edit_model { 'Event' }

sub change_fields
{
    return Dict[
        name        => Optional[Str],
        comment     => Nullable[Str],
        type_id     => Nullable[Int],
        setlist     => Nullable[Str],
        time        => Nullable[Str],
        begin_date  => Nullable[PartialDateHash],
        end_date    => Nullable[PartialDateHash],
        ended       => Optional[Bool],
        cancelled   => Optional[Bool],
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            gid => Optional[Str],
            name => Str
        ],
        new => change_fields(),
        old => change_fields(),
    ]
);

sub foreign_keys
{
    my ($self) = @_;
    my $relations = {};
    changed_relations($self->data, $relations, (
                         EventType => 'type_id',
                      ));
    $relations->{Event} = [ $self->data->{entity}{id} ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        type       => [ qw( type_id EventType )],
        name       => 'name',
        ended      => 'ended',
        cancelled  => 'cancelled',
        comment    => 'comment',
        address    => 'address',
        setlist    => 'setlist',
        time       => 'time',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{event} = $loaded->{Event}{ $self->data->{entity}{id} }
        || Event->new( name => $self->data->{entity}{name} );

    for my $date_prop (qw( begin_date end_date )) {
        if (exists $self->data->{new}{$date_prop}) {
            $data->{$date_prop} = {
                new => PartialDate->new($self->data->{new}{$date_prop}),
                old => PartialDate->new($self->data->{old}{$date_prop}),
            };
        }
    }

    return $data;
}

sub _mapping
{
    my $self = shift;

    return (
        begin_date => date_closure('begin_date'),
        end_date => date_closure('end_date'),
    );
}

sub allow_auto_edit
{
    my ($self) = @_;

    # Changing name is allowed if the change only affects
    # small things like case etc.
    my ($old_name, $new_name) = normalise_strings(
        $self->data->{old}{name}, $self->data->{new}{name});

    return 0 if $old_name ne $new_name;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    # Adding a date is automatic if there was no date yet.
    return 0 if exists $self->data->{old}{begin_date}
        and MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{old}{begin_date})->format ne '';
    return 0 if exists $self->data->{old}{end_date}
        and MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{old}{end_date})->format ne '';

    return 0 if exists $self->data->{old}{type_id}
        and $self->data->{old}{type_id} != 0;

    my ($old_time, $new_time) = normalise_strings(
        $self->data->{old}{time}, $self->data->{new}{time});
    return 0 if $old_time ne $new_time;

    my ($old_setlist, $new_setlist) = normalise_strings(
        $self->data->{old}{setlist}, $self->data->{new}{setlist});
    return 0 if $old_setlist ne $new_setlist;

    return 1;
}

sub current_instance {
    my $self = shift;
    my $event = $self->c->model('Event')->get_by_id($self->entity_id);
    return $event;
}

sub _edit_hash {
    my ($self, $data) = @_;
    return $self->merge_changes;
}

around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    given ($property) {
        when ('begin_date') {
            return merge_partial_date('begin_date' => $ancestor, $current, $new);
        }

        when ('end_date') {
            return merge_partial_date('end_date' => $ancestor, $current, $new);
        }

        default {
            return ($self->$orig(@_));
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
