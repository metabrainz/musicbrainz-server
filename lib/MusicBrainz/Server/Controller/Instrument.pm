package MusicBrainz::Server::Controller::Instrument;
use Moose;
use namespace::autoclean;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw(
    $EDIT_INSTRUMENT_CREATE
    $EDIT_INSTRUMENT_EDIT
    $EDIT_INSTRUMENT_MERGE
    $EDIT_INSTRUMENT_DELETE
);
use List::AllUtils qw( sort_by uniq );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Instrument',
    entity_name     => 'instrument',
    relationships   => { cardinal => ['show', 'edit'], default => ['url'] },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';
with 'MusicBrainz::Server::Controller::Role::CommonsImage';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_type => 'instrument'
};

sub base : Chained('/') PathPart('instrument') CaptureArgs(0) { }

sub show : PathPart('') Chained('load') {
    my ($self, $c) = @_;

    my %props = (
        instrument        => $c->stash->{instrument}->TO_JSON,
        numberOfRevisions => $c->stash->{number_of_revisions},
        wikipediaExtract  => to_json_object($c->stash->{wikipedia_extract}),
    );

    $c->stash(
        component_path => 'instrument/InstrumentIndex',
        component_props => \%props,
        current_view => 'Node',
    );
}

after 'load' => sub {
    my ($self, $c) = @_;
    my $instrument = $c->stash->{instrument};
    $c->model('InstrumentType')->load($instrument);
};

sub artists : Chained('load') {
    my ($self, $c) = @_;

    my $instrument = $c->stash->{instrument};
    my ($results, @artists, %instrument_credits_and_rel_types);

    $results = $self->_load_paged($c, sub {
        $c->model('Artist')->find_by_instrument($instrument->id, shift, shift);
    });

    for my $item (@$results) {
        push @artists, $item->{artist};
        my @credits_and_rel_types = uniq grep { $_ } @{ $item->{instrument_credits_and_rel_types} // [] };
        $instrument_credits_and_rel_types{$item->{artist}->gid} = \@credits_and_rel_types if @credits_and_rel_types;
    }

    $c->model('Artist')->load_meta(@artists);
    $c->model('ArtistType')->load(@artists);
    $c->model('Gender')->load(@artists);
    $c->model('Area')->load(@artists);

    if ($c->user_exists) {
        $c->model('Artist')->rating->load_user_ratings($c->user->id, @artists);
    }

    my %props = (
        artists => to_json_array(\@artists),
        instrument => $c->stash->{instrument}->TO_JSON,
        instrumentCreditsAndRelTypes => \%instrument_credits_and_rel_types,
        pager => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path => 'instrument/InstrumentArtists',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub recordings : Chained('load') {
    my ($self, $c) = @_;

    my $instrument = $c->stash->{instrument};
    my ($results, @recordings, %instrument_credits_and_rel_types);

    $results = $self->_load_paged($c, sub {
        $c->model('Recording')->find_by_instrument($instrument->id, shift, shift);
    });

    for my $item (@$results) {
        push @recordings, $item->{recording};
        my @credits_and_rel_types = uniq grep { $_ } @{ $item->{instrument_credits_and_rel_types} // [] };
        $instrument_credits_and_rel_types{$item->{recording}->gid} = \@credits_and_rel_types if @credits_and_rel_types;
    }

    $c->model('Recording')->load_meta(@recordings);

    if ($c->user_exists) {
        $c->model('Recording')->rating->load_user_ratings($c->user->id, @recordings);
    }

    $c->model('ISRC')->load_for_recordings(@recordings);
    $c->model('ArtistCredit')->load(@recordings);

    my %props = (
        instrument => $c->stash->{instrument}->TO_JSON,
        instrumentCreditsAndRelTypes => \%instrument_credits_and_rel_types,
        pager => serialize_pager($c->stash->{pager}),
        recordings => to_json_array(\@recordings),
    );

    $c->stash(
        component_path => 'instrument/InstrumentRecordings',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub releases : Chained('load') {
    my ($self, $c) = @_;

    my $instrument = $c->stash->{instrument};
    my ($results, @releases, %instrument_credits_and_rel_types);

    $results = $self->_load_paged($c, sub {
        $c->model('Release')->find_by_instrument($instrument->id, shift, shift);
    });

    for my $item (@$results) {
        push @releases, $item->{release};
        my @credits_and_rel_types = uniq grep { $_ } @{ $item->{instrument_credits_and_rel_types} // [] };
        $instrument_credits_and_rel_types{$item->{release}->gid} = \@credits_and_rel_types if @credits_and_rel_types;
    }

    $c->model('ArtistCredit')->load(@releases);
    $c->model('Release')->load_related_info(@releases);

    my %props = (
        instrument => $c->stash->{instrument}->TO_JSON,
        instrumentCreditsAndRelTypes => \%instrument_credits_and_rel_types,
        pager => serialize_pager($c->stash->{pager}),
        releases => to_json_array(\@releases),
    );

    $c->stash(
        component_path => 'instrument/InstrumentReleases',
        component_props => \%props,
        current_view => 'Node',
    );
}

after [qw( show collections details tags aliases artists releases recordings )] => sub {
    my ($self, $c) = @_;
    $self->_stash_collections($c);
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Instrument',
    edit_type      => $EDIT_INSTRUMENT_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_INSTRUMENT_MERGE,
};

sub _merge_load_entities {
    my ($self, $c, @instruments) = @_;
    $c->model('InstrumentType')->load(@instruments);
};

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Instrument',
    edit_type => $EDIT_INSTRUMENT_CREATE,
    dialog_template => 'instrument/edit_form.tt',
};

with 'MusicBrainz::Server::Controller::Role::Delete' => {
    edit_type => $EDIT_INSTRUMENT_DELETE,
};

for my $method (qw( create edit merge merge_queue delete add_alias edit_alias delete_alias edit_annotation )) {
    before $method => sub {
        my ($self, $c) = @_;
        if (!$c->user->is_relationship_editor) {
            $c->detach('/error_403');
        }
    };
};

sub list : Path('/instruments') Args(0) {
    my ($self, $c) = @_;

    my @instruments = $c->model('Instrument')->get_all;
    my $coll = $c->get_collator();
    my @sorted = sort_by { $coll->getSortKey($_->l_name) } @instruments;

    my @types = $c->model('InstrumentType')->get_all();

    my $entities = {};
    for my $i (@sorted) {
        my $type = $i->type_id || 'unknown';
        push @{ $entities->{$type} }, $i->TO_JSON;
    }

    $c->stash(
        current_view => 'Node',
        component_path => 'instrument/List',
        component_props => {
            %{$c->stash->{component_props}},
            instruments_by_type => $entities,
            instrument_types => to_json_array(\@types),
        }
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
