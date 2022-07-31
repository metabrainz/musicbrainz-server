package MusicBrainz::Server::Controller::Mood;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use List::AllUtils qw( sort_by );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Mood',
    entity_name     => 'mood',
    relationships   => { cardinal => ['show', 'edit'], default => ['url'] },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';

use MusicBrainz::Server::Constants qw(
    $EDIT_MOOD_CREATE
    $EDIT_MOOD_EDIT
    $EDIT_MOOD_DELETE
);

sub base : Chained('/') PathPart('mood') CaptureArgs(0) { }

after 'load' => sub {
    my ($self, $c) = @_;
    my $entity_name = $self->{entity_name};
    my $entity = $c->stash->{ $entity_name };
    $c->stash(
        can_delete => $c->model('Mood')->can_delete($entity->id)
    );
};

sub show : PathPart('') Chained('load') {
    my ($self, $c) = @_;

    $c->stash(
        component_path => 'mood/MoodIndex',
        component_props => {mood => $c->stash->{mood}->TO_JSON},
        current_view => 'Node',
    );
}

sub _form_to_hash {
    my ($self, $form) = @_;
    return map { $form->field($_)->name => $form->field($_)->value } $form->edit_field_names;
}

sub _redirect_to_mood {
    my ($self, $c, $gid) = @_;
    $c->response->redirect($c->uri_for_action($self->action_for('show'), [ $gid ]));
}

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Mood',
    edit_type => $EDIT_MOOD_CREATE,
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form      => 'Mood',
    edit_type => $EDIT_MOOD_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Delete' => {
    edit_type      => $EDIT_MOOD_DELETE,
};

for my $method (qw( create edit delete add_alias edit_alias delete_alias edit_annotation )) {
    before $method => sub {
        my ($self, $c) = @_;
        if (!$c->user->is_relationship_editor) {
            $c->detach('/error_403');
        }
    };
};

sub list : Path('/moods') Args(0) {
    my ($self, $c) = @_;

    my @moods = $c->model('Mood')->get_all;
    my $coll = $c->get_collator();
    my @sorted_moods = sort_by { $coll->getSortKey($_->name) } @moods;

    $c->stash(
        current_view => 'Node',
        component_path => 'mood/MoodListPage',
        component_props => { moods => to_json_array(\@sorted_moods) },
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
