package MusicBrainz::Server::Controller::WS::2::Tag;
use Moose;

use English;

BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Data::Utils qw( non_empty trim type_to_model );
use MusicBrainz::Server::Validation qw( is_guid );
use MusicBrainz::Server::WebService::XML::XPath;

no if $] >= 5.018, warnings => 'experimental::smartmatch';

my $ws_defs = Data::OptList::mkopt([
     tag => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     tag => {
                         method   => 'GET',
                         required => [ qw(id entity) ],
                         optional => [ qw(fmt) ],
     },
     tag => {
                         method   => 'POST',
                         optional => [ qw(client) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub tag_lookup : Private
{
    my ($self, $c) = @_;

    my ($entity, $model) = $self->_validate_entity($c);

    my @tags = $c->model($model)->tags->find_user_tags($c->user->id, $entity->id);

    my $stash = WebServiceStash->new;
    $stash->store($entity)->{user_tags} = \@tags;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('user-tag-list', $entity, $c->stash->{inc}, $stash));
}


sub tag_search : Chained('root') PathPart('tag') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('tag_submit') if $c->request->method eq 'POST';
    $c->detach('tag_lookup') if exists $c->stash->{args}->{id};

    $self->_search($c, 'tag');
}

sub tag_submit : Private
{
    my ($self, $c) = @_;

    $self->deny_readonly($c);
    $self->_validate_post($c);

    my $xp = MusicBrainz::Server::WebService::XML::XPath->new( xml => $c->request->body );
    my @nodelist;
    eval {
        @nodelist = $xp->find('/mb:metadata/*/*')->get_nodelist;
    };
    if ($EVAL_ERROR) {
        $self->_error($c, 'Invalid XML.');
    }

    my $submit = {};
    for my $node (@nodelist)
    {
        my $type = $node->getLocalName;
        $type =~ s/-/_/;

        my $model = type_to_model($type);
        $self->_error($c, "Unrecognized entity $type.") unless $model;

        my $gid = $xp->find('@mb:id', $node)->string_value;
        $self->_error($c, "Cannot parse MBID: $gid.")
            unless is_guid($gid);

        my $entity = $c->model($model)->get_by_gid($gid);
        $self->_error($c, "Cannot find $type $gid.") unless $entity;

        my @new_user_tags = $xp->find('mb:user-tag-list/mb:user-tag', $node)->get_nodelist;
        my $has_votes;

        for (@new_user_tags) {
            my $name = lc trim $xp->find('mb:name', $_)->string_value;
            $self->_error($c, 'The tag name cannot be empty.')
                unless non_empty($name);
            my $vote = 'upvote';

            if ($xp->exists('@mb:vote', $_)) {
                # If none of the user-tag nodes have 'vote' attributes, assume
                # the legacy behavior of treating the submission as the entire
                # set of 'upvoted' tags.
                $has_votes = 1;

                $vote = $xp->find('@mb:vote', $_)->string_value;
                unless ($vote ~~ [qw(upvote downvote withdraw)]) {
                    $self->_error($c, 'Unrecognized vote type: ' . $vote);
                }
            }
            push @{ $submit->{$name} //= [] }, [$model, $vote, $entity->id];
        }

        unless ($has_votes) {
            # Legacy behavior: withdraw upvotes for tags not in the submission.
            my @old_user_tags = $c->model($model)->tags->find_user_tags($c->user->id, $entity->id);

            for (@old_user_tags) {
                if (!exists($submit->{$_->tag->name}) && $_->is_upvote) {
                    $submit->{$_->tag->name} = [[$model, 'withdraw', $entity->id]];
                }
            }
        }
    }

    while (my ($tag, $args) = each %$submit) {
        for (@$args) {
            my ($model, $vote, $entity_id) = @$_;
            $c->model($model)->tags->$vote($c->user->id, $entity_id, $tag);
        }
    }

    $c->detach('success');
}

__PACKAGE__->meta->make_immutable;
1;

