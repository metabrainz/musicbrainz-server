package MusicBrainz::Server::Controller::Genre;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use List::AllUtils qw( sort_by );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Genre',
    entity_name     => 'genre',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Details';

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
        component_props => {genre => $c->stash->{genre}->TO_JSON},
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

sub create : Local RequireAuth(relationship_editor) Edit {
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Genre' );

    if ($c->form_posted_and_valid($form)) {
        my %insert = $self->_form_to_hash($form);
        my $genre = $c->model('MB')->with_transaction(sub {
            $c->model('Genre')->insert(\%insert);
        });

        $self->_redirect_to_genre($c, $genre->{gid});
    }

    $c->stash(
        component_path => 'genre/CreateGenre',
        component_props => {form => $form->TO_JSON},
        current_view => 'Node',
    );
}

sub edit : Chained('load') RequireAuth(relationship_editor) {
    my ($self, $c) = @_;

    my $genre = $c->stash->{genre};

    my $form = $c->form( form => 'Genre', init_object => $genre );

    if ($c->form_posted_and_valid($form)) {
        my %update = $self->_form_to_hash($form);

        $c->model('MB')->with_transaction(sub {
            $c->model('Genre')->update($genre->{id}, \%update);
        });
        $self->_redirect_to_genre($c, $genre->{gid});
    }

    my %props = (
        form => $form->TO_JSON,
        genre => $genre->TO_JSON,
    );

    $c->stash(
        component_path => 'genre/EditGenre',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub delete : Chained('load') RequireAuth(relationship_editor) {
    my ($self, $c) = @_;

    my $genre = $c->stash->{genre};

    if ($c->form_posted) {
        $c->model('MB')->with_transaction(sub {
            $c->model('Genre')->delete($genre->{id});
        });

        $c->response->redirect($c->uri_for_action('genre/list'));
    }

    $c->stash(
        component_path => 'genre/DeleteGenre',
        component_props => {genre => $genre->TO_JSON},
        current_view => 'Node',
    );
}

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
