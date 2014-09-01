package MusicBrainz::Server::Controller::Instrument;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw(
    $EDIT_INSTRUMENT_CREATE
    $EDIT_INSTRUMENT_EDIT
    $EDIT_INSTRUMENT_MERGE
    $EDIT_INSTRUMENT_DELETE
);
use MusicBrainz::Server::Translation qw( l );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Instrument',
    entity_name => 'instrument',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';
with 'MusicBrainz::Server::Controller::Role::CommonsImage';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';

sub base : Chained('/') PathPart('instrument') CaptureArgs(0) { }

sub show : PathPart('') Chained('load') {
    my ($self, $c) = @_;

    $c->stash->{template} = 'instrument/index.tt';
}

after 'load' => sub {
    my ($self, $c) = @_;
    my $instrument = $c->stash->{instrument};
    $c->model('InstrumentType')->load($instrument);
    $self->load_relationships($c);
};

sub recordings : Chained('load') {
    my ($self, $c) = @_;

    my $instrument = $c->stash->{instrument};
    my $recordings;

    $recordings = $self->_load_paged($c, sub {
        $c->model('Recording')->find_by_instrument($instrument->id, shift, shift);
    });

    $c->model('Recording')->load_meta(@$recordings);

    if ($c->user_exists) {
        $c->model('Recording')->rating->load_user_ratings($c->user->id, @$recordings);
    }

    $c->stash( template => 'instrument/recordings.tt' );

    $c->model('ISRC')->load_for_recordings(@$recordings);
    $c->model('ArtistCredit')->load(@$recordings);

    $c->stash(
        recordings => $recordings,
    );
}

sub releases : Chained('load') {
    my ($self, $c) = @_;

    my $instrument = $c->stash->{instrument};
    my $releases;

    $releases = $self->_load_paged($c, sub {
            $c->model('Release')->find_by_instrument($instrument->id, shift, shift);
        });

    $c->stash( template => 'instrument/releases.tt' );

    $c->model('ArtistCredit')->load(@$releases);
    $c->model('Medium')->load_for_releases(@$releases);
    $c->model('MediumFormat')->load(map { $_->all_mediums } @$releases);
    $c->model('Release')->load_release_events(@$releases);
    $c->model('ReleaseLabel')->load(@$releases);
    $c->model('Label')->load(map { $_->all_labels } @$releases);
    $c->stash(
        releases => $releases,
    );
}

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

1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
