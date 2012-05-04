package MusicBrainz::Server::Controller::Work;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw(
    $EDIT_WORK_CREATE
    $EDIT_WORK_EDIT
    $EDIT_WORK_MERGE
    $EDIT_WORK_ADD_ISWCS
);

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Work',
    entity_name => 'work',
};
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Cleanup';

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';

sub base : Chained('/') PathPart('work') CaptureArgs(0) { }

after 'load' => sub
{
    my ($self, $c) = @_;

    my $work = $c->stash->{work};
    $c->model('Work')->load_meta($work);
    $c->model('ISWC')->load_for_works($work);
    if ($c->user_exists) {
        $c->model('Work')->rating->load_user_ratings($c->user->id, $work);
    }
};

sub show : PathPart('') Chained('load') 
{
    my ($self, $c) = @_;

    my $work = $c->stash->{work};
    $c->model('WorkType')->load($work);

    # need to call relationships for overview page
    $self->relationships($c);


    $c->stash->{template} = 'work/index.tt';
}

for my $action (qw( relationships aliases tags details add_iswc )) {
    after $action => sub {
        my ($self, $c) = @_;
        my $work = $c->stash->{work};
        $c->model('WorkType')->load($work);
    };
}

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Work',
    edit_type      => $EDIT_WORK_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_WORK_MERGE,
    confirmation_template => 'work/merge_confirm.tt',
    search_template       => 'work/merge_search.tt',
};

before 'edit' => sub
{
    my ($self, $c) = @_;
    my $work = $c->stash->{work};
    $c->model('WorkType')->load($work);
};

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Work',
    edit_type => $EDIT_WORK_CREATE,
};

sub add_iswc : Chained('load') PathPart('add-iswc') RequireAuth
{
    my ($self, $c) = @_;

    my $work = $c->stash->{work};
    my $form = $c->form(form => 'AddISWC');
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $self->_insert_edit(
            $c, $form,
            edit_type => $EDIT_WORK_ADD_ISWCS,
            iswcs => [ {
                iswc => $form->field('iswc')->value,
                work => {
                    id => $work->id,
                    name => $work->name
                }
            } ]
        );

        if ($c->stash->{makes_no_changes}) {
            $form->field('iswc')->add_error(l('This ISWC already exists for this work'));
        }
        else {
            $c->response->redirect($c->uri_for_action('/work/show', [ $work->gid ]));
            $c->detach;
        }
    }
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
