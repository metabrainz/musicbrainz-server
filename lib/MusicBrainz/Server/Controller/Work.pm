package MusicBrainz::Server::Controller::Work;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw( $EDIT_WORK_EDIT );

with 'MusicBrainz::Server::Controller::Annotation';
with 'MusicBrainz::Server::Controller::DetailsRole';
with 'MusicBrainz::Server::Controller::RelationshipRole';
with 'MusicBrainz::Server::Controller::RatingRole';
with 'MusicBrainz::Server::Controller::TagRole';
with 'MusicBrainz::Server::Controller::EditListingRole';

__PACKAGE__->config(
    model       => 'Work',
    entity_name => 'work',
);

sub base : Chained('/') PathPart('work') CaptureArgs(0) { }

after 'load' => sub
{
    my ($self, $c) = @_;

    my $work = $c->stash->{work};
    $c->model('Work')->load_meta($work);
    if ($c->user_exists) {
        $c->model('Work')->rating->load_user_ratings($c->user->id, $work);
    }
};

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $work = $c->stash->{work};
    $c->model('WorkType')->load($work);
    $c->model('ArtistCredit')->load($work);

    $c->stash->{template} = 'work/index.tt';
}

sub edit : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;

    my $work = $c->stash->{work};
    $c->model('WorkType')->load($work);
    $c->model('ArtistCredit')->load($work);

    my $form = $c->form(form => 'Work', init_object => $work);
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $edit = $c->model('Edit')->create(
            editor_id => $c->user->id,
            edit_type => $EDIT_WORK_EDIT,
            work => $work,

            (map { $_ => $form->field($_)->value }
                 grep { $form->field($_)->has_value }
                     qw( type_id name comment iswc artist_credit ))
        );

        $c->response->redirect($c->uri_for_action('/work/show', [ $work->gid ]));
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
