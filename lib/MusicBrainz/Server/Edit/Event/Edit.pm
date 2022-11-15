package MusicBrainz::Server::Edit::Event::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw(
    $EDIT_EVENT_CREATE
    $EDIT_EVENT_EDIT
);
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    date_closure
    merge_partial_date
    merge_time
    time_closure
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Validation qw( normalise_strings );

use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Event';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

no if $] >= 5.018, warnings => 'experimental::smartmatch';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Event';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_EVENT_CREATE,
    entity_type => 'event',
};
with 'MusicBrainz::Server::Edit::Role::DatePeriod';

sub edit_name { N_l('Edit event') }
sub edit_type { $EDIT_EVENT_EDIT }
sub edit_template { 'EditEvent' }

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
            gid => Str,
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

    $data->{event} = to_json_object(
        $loaded->{Event}{ $self->data->{entity}{id} } ||
        Event->new( name => $self->data->{entity}{name} )
    );

    for my $date_prop (qw( begin_date end_date )) {
        if (exists $self->data->{new}{$date_prop}) {
            $data->{$date_prop} = {
                new => to_json_object(PartialDate->new($self->data->{new}{$date_prop})),
                old => to_json_object(PartialDate->new($self->data->{old}{$date_prop})),
            };
        }
    }

    if (exists $data->{cancelled}) {
        $data->{cancelled}{old} = boolean_to_json($data->{cancelled}{old});
        $data->{cancelled}{new} = boolean_to_json($data->{cancelled}{new});
    }

    if (exists $data->{type}) {
        $data->{type}{old} = to_json_object($data->{type}{old});
        $data->{type}{new} = to_json_object($data->{type}{new});
    }

    return $data;
}

sub _mapping
{
    my $self = shift;

    return (
        begin_date => date_closure('begin_date'),
        end_date => date_closure('end_date'),
        time => time_closure('time'),
    );
}

around allow_auto_edit => sub {
    my ($orig, $self, @args) = @_;

    return 1 if $self->can_amend($self->entity_id);

    foreach my $prop (qw(time setlist)) {
        my ($old_prop, $new_prop) = normalise_strings(
            $self->data->{old}{$prop}, $self->data->{new}{$prop});
        return 0 if $old_prop ne '' && $old_prop ne $new_prop;
    }

    return $self->$orig(@args);
};

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

        when ('time') {
            return merge_time('time' => $ancestor, $current, $new);
        }

        default {
            return ($self->$orig(@_));
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
