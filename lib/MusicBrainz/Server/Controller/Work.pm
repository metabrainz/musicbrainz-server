package MusicBrainz::Server::Controller::Work;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw(
    $EDIT_WORK_CREATE
    $EDIT_WORK_EDIT
    $EDIT_WORK_MERGE
    $EDIT_WORK_ADD_ISWCS
    $EDIT_WORK_REMOVE_ISWC
);
use MusicBrainz::Server::Translation qw( l );

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
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';

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
    $c->model('Language')->load($work);
    $c->model('Work')->load_writers($work);

    # need to call relationships for overview page
    $self->relationships($c);

    $c->stash->{template} = 'work/index.tt';
}

for my $action (qw( relationships aliases tags details )) {
    after $action => sub {
        my ($self, $c) = @_;
        my $work = $c->stash->{work};
        $c->model('WorkType')->load($work);
        $c->model('Language')->load($work);
    };
}

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Work',
    edit_type      => $EDIT_WORK_EDIT,
    edit_arguments => sub {
        my ($self, $c, $work) = @_;

        return (
            post_creation => sub {
                my ($edit, $form) = @_;

                my @current_iswcs = $c->model('ISWC')->find_by_works($work->id);
                my %current_iswcs = map { $_->iswc => 1 } @current_iswcs;
                my @submitted = @{ $form->field('iswcs')->value };
                my %submitted = map { $_ => 1 } @submitted;

                my @added = grep { !exists($current_iswcs{$_}) } @submitted;
                my @removed = grep { !exists($submitted{$_->iswc}) } @current_iswcs;

                $self->_add_iswcs($c, $form, $work, @added) if @added;
                $self->_remove_iswcs($c, $form, $work, @removed) if @removed;

                if ((@added || @removed) && $c->stash->{makes_no_changes}) {
                    $c->stash( makes_no_changes => 0 );
                    $c->response->redirect(
                        $c->uri_for_action($self->action_for('show'), [ $work->gid ]));
                }
            }
        );
    }
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

after 'merge' => sub
{
    my ($self, $c) = @_;
    $c->model('Work')->load_meta(@{ $c->stash->{to_merge} });
    $c->model('WorkType')->load(@{ $c->stash->{to_merge} });
    if ($c->user_exists) {
        $c->model('Work')->rating->load_user_ratings($c->user->id, @{ $c->stash->{to_merge} });
    }
    $c->model('Work')->load_writers(@{ $c->stash->{to_merge} });
    $c->model('Work')->load_recording_artists(@{ $c->stash->{to_merge} });
    $c->model('Language')->load(@{ $c->stash->{to_merge} });
    $c->model('ISWC')->load_for_works(@{ $c->stash->{to_merge} });
};

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Work',
    edit_type => $EDIT_WORK_CREATE,
    edit_arguments => sub {
        my ($self, $c) = @_;

        return (
            post_creation => sub {
                my ($edit, $form) = @_;
                my $work = $c->model('Work')->get_by_id($edit->entity_id);
                my @iswcs = @{ $form->field('iswcs')->value };
                $self->_add_iswcs($c, $form, $work, @iswcs) if scalar @iswcs;
            }
        );
    }
};

sub _add_iswcs {
    my ($self, $c, $form, $work, @iswcs) = @_;

    $c->model('MB')->with_transaction(sub {
        $self->_insert_edit(
            $c, $form,
            edit_type => $EDIT_WORK_ADD_ISWCS,
            iswcs => [ map {
                iswc => $_,
                work => {
                    id => $work->id,
                    name => $work->name
                }
            }, @iswcs ]
        );
    });
}

sub _remove_iswcs {
    my ($self, $c, $form, $work, @iswcs) = @_;

    $c->model('MB')->with_transaction(sub {
        $self->_insert_edit(
            $c, $form,
            edit_type => $EDIT_WORK_REMOVE_ISWC,
            iswc => $_,
            work => $work
        );
    }) for @iswcs;
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
