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
use List::UtilsBy qw( sort_by );

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

    $c->stash->{template} = 'instrument/index.tt';
}

after 'load' => sub {
    my ($self, $c) = @_;
    my $instrument = $c->stash->{instrument};
    $c->model('InstrumentType')->load($instrument);
};

sub recordings : Chained('load') {
    my ($self, $c) = @_;

    my $instrument = $c->stash->{instrument};
    my ($results, @recordings, %instrument_credits);

    $results = $self->_load_paged($c, sub {
        $c->model('Recording')->find_by_instrument($instrument->id, shift, shift);
    });

    for my $item (@$results) {
        push @recordings, $item->{recording};
        my @credits = grep { $_ } @{ $item->{instrument_credits} // [] };
        $instrument_credits{$item->{recording}->gid} = \@credits if @credits;
    }

    $c->model('Recording')->load_meta(@recordings);

    if ($c->user_exists) {
        $c->model('Recording')->rating->load_user_ratings($c->user->id, @recordings);
    }

    $c->stash( template => 'instrument/recordings.tt' );

    $c->model('ISRC')->load_for_recordings(@recordings);
    $c->model('ArtistCredit')->load(@recordings);

    $c->stash(
        recordings => \@recordings,
        instrument_credits => \%instrument_credits,
    );
}

sub releases : Chained('load') {
    my ($self, $c) = @_;

    my $instrument = $c->stash->{instrument};
    my ($results, @releases, %instrument_credits);

    $results = $self->_load_paged($c, sub {
        $c->model('Release')->find_by_instrument($instrument->id, shift, shift);
    });

    for my $item (@$results) {
        push @releases, $item->{release};
        my @credits = grep { $_ } @{ $item->{instrument_credits} // [] };
        $instrument_credits{$item->{release}->gid} = \@credits if @credits;
    }

    $c->stash( template => 'instrument/releases.tt' );

    $c->model('ArtistCredit')->load(@releases);
    $c->model('Release')->load_related_info(@releases);
    $c->stash(
        releases => \@releases,
        instrument_credits => \%instrument_credits,
    );
}

after [qw( show collections details tags aliases recordings releases )] => sub {
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
        my $type = $i->{type_id} || "unknown";
        push @{ $entities->{$type} }, $i;
    }

    $c->stash(
        entities => $entities,
        types => \@types,
    );
}

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
