package MusicBrainz::Server::Edit::Recording::Edit;
use Moose;
use 5.10.0;

use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_EDIT );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    clean_submitted_artist_credits
    changed_relations
    changed_display_data
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
    verify_artist_credits
    merge_artist_credit
    boolean_to_json
    boolean_from_json
);
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Validation qw( normalise_strings );

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';
with 'MusicBrainz::Server::Edit::Recording';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

use aliased 'MusicBrainz::Server::Entity::Recording';

sub edit_type { $EDIT_RECORDING_EDIT }
sub edit_name { N_l('Edit recording') }
sub _edit_model { 'Recording' }
sub recording_id { return shift->entity_id }

around _build_related_entities => sub {
    my ($orig, $self, @args) = @_;
    my %rel = %{ $self->$orig(@args) };
    if ($self->data->{new}{artist_credit}) {
        my %new = load_artist_credit_definitions($self->data->{new}{artist_credit});
        my %old = load_artist_credit_definitions($self->data->{old}{artist_credit});
        push @{ $rel{artist} }, keys(%new), keys(%old);
    }

    return \%rel;
};

sub change_fields
{
    Dict[
        name          => Optional[Str],
        artist_credit => Optional[ArtistCreditDefinition],
        length        => Nullable[Int],
        comment       => Nullable[Str],
        video         => Optional[Bool]
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            gid => Optional[Str],
            name => Str
        ],
        old => change_fields(),
        new => change_fields(),
    ]
);

sub to_hash {
    my $data = shift->data;

    for ($data->{old}, $data->{new}) {
        $_->{video} = boolean_to_json($_->{video}) if exists $_->{video};
    }

    return $data;
}

sub restore {
    my ($self, $data) = @_;

    for ($data->{old}, $data->{new}) {
        $_->{video} = boolean_from_json($_->{video}) if exists $_->{video};
    }

    $self->data($data);
}

sub current_instance {
    my $self = shift;
    return $self->c->model('Recording')->get_by_id($self->entity_id);
}

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations);

    if (exists $self->data->{new}{artist_credit}) {
        $relations->{Artist} = {
            map {
                load_artist_credit_definitions($self->data->{$_}{artist_credit})
            } qw( new old )
        }
    }

    $relations->{Recording} = { $self->data->{entity}{id} => [ 'ArtistCredit' ] };

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name    => 'name',
        comment => 'comment',
        length  => 'length',
        video   => 'video',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    if (exists $self->data->{new}{artist_credit}) {
        $data->{artist_credit} = {
            new => artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit}),
            old => artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit})
        }
    }

    $data->{recording} = $loaded->{Recording}{ $self->data->{entity}{id} }
        || Recording->new( name => $self->data->{entity}{name} );

    return $data;
}

around 'initialize' => sub
{
    my ($orig, $self, %opts) = @_;
    my $recording = $opts{to_edit} or return;
    if (exists $opts{artist_credit} && !$recording->artist_credit) {
        $self->c->model('ArtistCredit')->load($recording);
    }

    delete $opts{length} if exists $opts{length} &&
        $self->c->model('Recording')->usage_count($recording->id);

    $opts{artist_credit} = clean_submitted_artist_credits($opts{artist_credit})
        if exists($opts{artist_credit});

    $opts{video} = boolean_from_json($opts{video}) if exists $opts{video};

    $self->$orig(%opts);
};

sub _mapping
{
    return (
        artist_credit => sub {
            artist_credit_to_ref(shift->artist_credit)
        },
    );
}

sub _edit_hash
{
    my ($self, $data) = @_;

    $data = $self->merge_changes;

    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit})
        if (exists $data->{artist_credit});

    $data->{comment} //= '' if exists $data->{comment};

    return $data;
}

before accept => sub {
    my ($self) = @_;

    verify_artist_credits($self->c, $self->data->{new}{artist_credit});
};

around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    given ($property) {
        when ('artist_credit') {
            return merge_artist_credit($self->c, $ancestor, $current, $new);
        }

        default {
            return ($self->$orig(@_));
        }
    }
};

sub allow_auto_edit
{
    my $self = shift;

    my ($old_name, $new_name) = normalise_strings($self->data->{old}{name},
                                                  $self->data->{new}{name});
    return 0 if $old_name ne $new_name;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    return 0 if exists $self->data->{old}{video}
        and $self->data->{old}{video} != $self->data->{new}{video};

    return 0 if $self->data->{old}{length};
    return 0 if exists $self->data->{new}{artist_credit};

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

