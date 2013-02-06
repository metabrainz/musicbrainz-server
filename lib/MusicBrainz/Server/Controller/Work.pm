package MusicBrainz::Server::Controller::Work;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Entity::ISWC;
use MusicBrainz::Server::Entity::Tree::Work;
use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::NES::Controller::Utils qw( create_edit create_update );
use MusicBrainz::Server::Translation qw( l );

__PACKAGE__->config(
    tree_entity => 'MusicBrainz::Server::Entity::Tree::Work',
);

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'NES::Work',
    entity_name => 'work',
};

with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';

sub base : Chained('/') PathPart('work') CaptureArgs(0) { }

after 'load' => sub
{
    my ($self, $c) = @_;

    my $work = $c->stash->{work};
    $c->model('MB')->with_nes_transaction(sub {
        # $c->model('Work')->load_meta($work);
        $c->model('NES::Work')->load_revision($work);
        $c->model('NES::ISWC')->load_for_works($work);
        if ($c->user_exists) {
            $c->model('Work')->rating->load_user_ratings($c->user->id, $work);
        }
    });
};

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $work = $c->stash->{work};
    $c->model('WorkType')->load($work);
    $c->model('Language')->load($work);

    # Need to call relationships for overview page
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

sub edit : Chained('load') {
    my ($self, $c) = @_;

    create_update(
        $self, $c,
        form => 'Work::Edit',
        subject => $c->stash->{work},
        build_tree => \&work_tree
    );
}

sub work_tree {
    my $values = shift;
    return MusicBrainz::Server::Entity::Tree::Work->new(
        work => MusicBrainz::Server::Entity::Work->new($values),
        iswcs => [
            map { MusicBrainz::Server::Entity::ISWC->new(iswc => $_) }
                @{ $values->{iswcs} // [] }
        ]
    );
}

with 'MusicBrainz::Server::Controller::Role::Merge' => {
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
    $c->model('MB')->with_nes_transaction(sub {
        if ($c->user_exists) {
            $c->model('Work')->rating->load_user_ratings($c->user->id, @{ $c->stash->{to_merge} });
        }
        # $c->model('Work')->load_meta(@{ $c->stash->{to_merge} });
        # $c->model('Work')->load_writers(@{ $c->stash->{to_merge} });
        # $c->model('Work')->load_recording_artists(@{ $c->stash->{to_merge} });
        $c->model('Language')->load(@{ $c->stash->{to_merge} });
        $c->model('NES::Work')->load_iswcs(@{ $c->stash->{to_merge} });
        $c->model('WorkType')->load(@{ $c->stash->{to_merge} });
    });
};

sub create : Local Edit {
    my ($self, $c) = @_;

    create_edit(
        $self, $c,
        form => 'Work',
        on_post => sub {
            my ($values, $edit) = @_;

            return $c->model('NES::Work')->create(
                $edit, $c->user,
                work_tree($values)
            );
        }
    );
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
