package MusicBrainz::Server::Controller::Genre;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use List::AllUtils qw( sort_by );
use MusicBrainz::Server::Entity::Util::JSON qw(
    to_json_array
    to_json_object
);

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Genre',
    entity_name     => 'genre',
    relationships   => { cardinal => ['show', 'edit'], default => ['url'] },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';

use MusicBrainz::Server::Constants qw(
    $EDIT_GENRE_CREATE
    $EDIT_GENRE_EDIT
    $EDIT_GENRE_DELETE
);

sub base : Chained('/') PathPart('genre') CaptureArgs(0) { }

after 'load' => sub {
    my ($self, $c) = @_;
    my $entity_name = $self->{entity_name};
    my $entity = $c->stash->{ $entity_name };
    $c->stash(
        can_delete => $c->model('Genre')->can_delete($entity->id)
    );
};

sub show : PathPart('') Chained('load') {
    my ($self, $c) = @_;

    $c->stash(
        component_path => 'genre/GenreIndex',
        component_props => {
            genre => $c->stash->{genre}->TO_JSON,
            numberOfRevisions => $c->stash->{number_of_revisions},
            wikipediaExtract  => to_json_object(
                $c->stash->{wikipedia_extract}
            ),
        },
        current_view => 'Node',
    );
}

sub _form_to_hash {
    my ($self, $form) = @_;
    return map { $form->field($_)->name => $form->field($_)->value } $form->edit_field_names;
}

sub _redirect_to_genre {
    my ($self, $c, $gid) = @_;
    $c->response->redirect($c->uri_for_action($self->action_for('show'), [ $gid ]));
}

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Genre',
    edit_type => $EDIT_GENRE_CREATE,
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form      => 'Genre',
    edit_type => $EDIT_GENRE_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Delete' => {
    edit_type      => $EDIT_GENRE_DELETE,
};

for my $method (qw( create edit delete add_alias edit_alias delete_alias edit_annotation )) {
    before $method => sub {
        my ($self, $c) = @_;
        if (!$c->user->is_relationship_editor) {
            $c->detach('/error_403');
        }
    };
};

sub list : Path('/genres') Args(0) {
    my ($self, $c) = @_;

    my @genres = $c->model('Genre')->get_all;
    my $coll = $c->get_collator();
    my @sorted_genres = sort_by { $coll->getSortKey($_->name) } @genres;

    $c->stash(
        current_view => 'Node',
        component_path => 'genre/GenreListPage',
        component_props => { genres => to_json_array(\@sorted_genres) },
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
