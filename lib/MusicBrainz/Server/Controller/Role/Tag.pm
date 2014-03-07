package MusicBrainz::Server::Controller::Role::Tag;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use Readonly;

use List::MoreUtils qw( uniq );

requires 'load', '_load_paged';

Readonly my $TOP_TAGS_COUNT => 5;

after 'load' => sub
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $tags_model = $c->model($self->{model})->tags;
    my @tags = $tags_model->find_top_tags($entity->id, $TOP_TAGS_COUNT);
    my $count = $tags_model->find_tag_count($entity->id);
    my @user_tags = $tags_model->find_user_tags($c->user->id, $entity->id)
        if $c->user_exists;

    $c->stash(
        top_tags => \@tags,
        more_tags => $count > @tags,
        sidebar_user_tags => [ map { $_->tag->name } @user_tags ]
    );
};

sub tags : Chained('load') PathPart('tags')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $tags_model = $c->model($self->{model})->tags;

    my @user_tags = $tags_model->find_user_tags($c->user->id, $entity->id)
        if $c->user_exists;
    my $tags = $self->_load_paged($c, sub {
        $tags_model->find_tags($entity->id, shift, shift);
    });

    $c->stash(
        tags => $tags,
        user_tags => \@user_tags,
    );

    my @user_tag_names = map { $_->tag->name } @user_tags;
    my $form = $c->form( tag_form => 'Tag', init_object => {
        tags => join(', ', sort @user_tag_names)
    });

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $tags = $form->field('tags')->value;
        $tags_model->update($c->user->id, $entity->id, $tags);

        my $redirect = $c->uri_for_action($c->action, [ $entity->gid ], { saved => 1});
        $c->response->redirect($redirect);
        $c->detach;
    }
}

sub tag_async : Chained('load') PathPart('ajax/tag') DenyWhenReadonly
{
    my ($self, $c) = @_;

    if (!$c->user_exists) {
        $c->res->status(401);
        $c->res->body('{}');
        $c->detach;
    }

    my $entity = $c->stash->{$self->{entity_name}};
    my $tags_model = $c->model($self->{model})->tags;
    $tags_model->update($c->user->id, $entity->id, $c->req->params->{tags});

    my @user_tags = $tags_model->find_user_tags($c->user->id, $entity->id);
    my @tags = $c->model($self->{model})->tags->find_top_tags($entity->id, $TOP_TAGS_COUNT);
    my $count = $tags_model->find_tag_count($entity->id);

    my $response = {
        tags => [
            uniq sort map { $_->tag->name } @user_tags, @tags
        ],
        more => $count > @tags
    };

    $c->res->body(JSON::Any->new(utf8 => 1)->encode($response));
}

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles
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
