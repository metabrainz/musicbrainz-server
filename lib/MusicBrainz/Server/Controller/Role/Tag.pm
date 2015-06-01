package MusicBrainz::Server::Controller::Role::Tag;
use JSON;
use List::MoreUtils qw( uniq );
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use MusicBrainz::Server::Data::Utils qw( trim );
use Readonly;

requires 'load', '_load_paged';

Readonly my $TOP_TAGS_COUNT => 5;

after load => sub {
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $tags_model = $c->model($self->{model})->tags;
    my @tags = $tags_model->find_top_tags($entity->id, $TOP_TAGS_COUNT);
    my $count = $tags_model->find_tag_count($entity->id);
    my @user_tags = $tags_model->find_user_tags($c->user->id, $entity->id)
        if $c->user_exists;
    my $json = JSON->new->allow_blessed->convert_blessed;

    $c->stash(
        top_tags => \@tags,
        more_tags => $count > @tags,
        top_tags_json => $json->encode(\@tags),
        user_tags_json => $json->encode(\@user_tags),
    );
};

sub tags : Chained('load') PathPart('tags') {
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $tags_model = $c->model($self->{model})->tags;
    my $json = JSON->new->allow_blessed->convert_blessed;

    my $tags = $self->_load_paged($c, sub {
        $tags_model->find_tags($entity->id, shift, shift);
    });

    $c->stash(
        tags => $tags,
        tags_json => $json->encode($tags),
        template => 'entity/tags.tt',
    );
}

sub parse_tags {
    my ($input) = @_;

    # make sure the list contains only unique tags
    uniq grep { $_ } map { lc trim $_ } split ',', $input;
}

sub _vote_on_tags {
    my ($self, $c, $method) = @_;

    $c->res->headers->header('X-Robots-Tag' => 'noindex');
    if (!$c->user_exists) {
        $c->res->status(401);
        $c->res->body('{}');
        $c->detach;
    }

    my @tags = parse_tags($c->req->params->{tags});
    my $entity = $c->stash->{$self->{entity_name}};
    my $tags_model = $c->model($self->{model})->tags;
    my $json = JSON->new->utf8->allow_blessed->convert_blessed;

    $c->res->body($json->encode({
        updates => [map { $tags_model->$method($c->user->id, $entity->id, $_) } @tags]
    }));
}

for my $method (qw(upvote downvote withdraw)) {
    my $attributes = "Chained('load') PathPart('tags/$method') DenyWhenReadonly";
    eval "sub ${method}_tags : $attributes { shift->_vote_on_tags(shift, '$method') }";
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
