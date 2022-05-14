package MusicBrainz::Server::Edit::Mood::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_MOOD_EDIT );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Mood';

no if $] >= 5.018, warnings => 'experimental::smartmatch';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Mood';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_name { N_l('Edit mood') }
sub edit_type { $EDIT_MOOD_EDIT }

sub _edit_model { 'Mood' }
sub edit_template_react { 'EditMood' }

sub change_fields
{
    return Dict[
        name       => Optional[Str],
        comment    => Nullable[Str],
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
    $relations->{Mood} = [ $self->data->{entity}{id} ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name       => 'name',
        comment    => 'comment',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{mood} = to_json_object(
        $loaded->{Mood}{ $self->data->{entity}{id} }
        || Mood->new( name => $self->data->{entity}{name} )
    );

    return $data;
}

sub current_instance {
    my $self = shift;
    my $mood = $self->c->model('Mood')->get_by_id($self->entity_id);
    return $mood;
}

sub _edit_hash {
    my ($self, $data) = @_;
    return $self->merge_changes;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
