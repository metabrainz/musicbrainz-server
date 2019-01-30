package MusicBrainz::Server::Controller::Role::Tag;
use List::MoreUtils qw( uniq );
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use MusicBrainz::Server::Data::Utils qw( trim );
use Readonly;

requires 'load';

Readonly my $TOP_TAGS_COUNT => 5;

after load => sub {
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
        user_tags => \@user_tags,
        user_tags_json => $c->json->encode(\@user_tags),
    );
};

sub tags : Chained('load') PathPart('tags') {
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my @tags = $c->model($self->{model})->tags->find_tags($entity->id);
    my @display_tags = grep { $_->count > 0 && !$_->tag->is_genre_tag } @tags;
    my @display_genres = grep { $_->count > 0 && $_->tag->is_genre_tag } @tags;

    if ($entity->entity_type =~ /^(?:instrument|release_group)$/) {
        my %props = (
            entity        => $entity,
            allTags       => \@tags,
            userTags      => $c->stash->{user_tags},
            moreTags      => $c->stash->{more_tags},
        );

        $c->stash(
            component_path  => 'entity/Tags.js',
            component_props => \%props,
            current_view    => 'Node',
        );
    } else {
        $c->stash(
            display_tags   => \@display_tags,
            display_genres => \@display_genres,
            tags_json      => $c->json->encode(\@tags),
            template       => 'entity/tags.tt',
        );
    }
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

    $c->res->body($c->json->encode({
        updates => [map { $tags_model->$method($c->user->id, $entity->id, $_) } @tags]
    }));
}

sub upvote_tags : Chained('load') PathPart('tags/upvote') DenyWhenReadonly {
    shift->_vote_on_tags(shift, 'upvote');
}

sub downvote_tags : Chained('load') PathPart('tags/downvote') DenyWhenReadonly {
    shift->_vote_on_tags(shift, 'downvote');
}

sub withdraw_tags : Chained('load') PathPart('tags/withdraw') DenyWhenReadonly {
    shift->_vote_on_tags(shift, 'withdraw');
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
