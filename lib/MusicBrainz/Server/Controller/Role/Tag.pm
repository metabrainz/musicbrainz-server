package MusicBrainz::Server::Controller::Role::Tag;
use List::AllUtils qw( uniq );
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use MusicBrainz::Server::Data::Utils qw( trim );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use Readonly;

requires 'load';

Readonly my $TOP_TAGS_COUNT => 5;

after load => sub {
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my $tags_model = $c->model($self->{model})->tags;
    my @tags = $tags_model->find_top_tags($entity->id, $TOP_TAGS_COUNT);
    my $count = $tags_model->find_tag_count($entity->id);
    my @user_tags;

    if ($c->user_exists) {
        @user_tags = $tags_model->find_user_tags($c->user->id, $entity->id);
    }

    $c->model('Genre')->load(map { $_->tag } (@tags, @user_tags));
    my %genre_map = map { $_->name => $_->TO_JSON } $c->model('Genre')->get_all;

    $c->stash(
        genre_map => \%genre_map,
        top_tags => to_json_array(\@tags),
        more_tags => $count > @tags,
        user_tags => to_json_array(\@user_tags),
        user_tags_json => $c->json->encode(\@user_tags),
    );
};

sub tags : Chained('load') PathPart('tags') {
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my @tags = $c->model($self->{model})->tags->find_tags($entity->id);
    $c->model('Genre')->load(map { $_->tag } @tags);

    my %props = (
        entity        => $entity->TO_JSON,
        allTags       => to_json_array(\@tags),
        userTags      => $c->stash->{user_tags},
        moreTags      => $c->stash->{more_tags},
    );

    $c->stash(
        component_path  => 'entity/Tags',
        component_props => \%props,
        current_view    => 'Node',
    );
}

sub parse_tags {
    my ($input) = @_;

    # make sure the list contains only unique tags
    uniq grep { $_ } map { lc trim $_ } split q(,), $input;
}

sub _vote_on_tags {
    my ($self, $c, $method) = @_;

    $c->res->headers->header('X-Robots-Tag' => 'noindex');
    if (!$c->user_exists || !$c->user->has_confirmed_email_address) {
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
