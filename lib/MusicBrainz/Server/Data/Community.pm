package MusicBrainz::Server::Data::Community;
use Moose;
use namespace::autoclean;

use Readonly;
use Try::Tiny;
use JSON qw(decode_json);

with 'MusicBrainz::Server::Data::Role::Context';

Readonly my $COMMUNITY_POSTS_CACHE_TIMEOUT => 60 * 60 * 3; # 3 hours

sub get_latest_posts {
    my ($self) = @_;

    my $key = 'community:posts';

    my $cache = $self->c->cache_manager->cache('community');
    my $posts = $cache->get($key);

    if (!$posts) {
        my $response;
        try {
            $response = $self->c->lwp->get('https://community.metabrainz.org/c/musicbrainz/6.json');
        } catch {
            $self->c->log->error("Failed to fetch community posts: $_");
            return undef;
        };

        return undef unless $response && $response->is_success;

        try {
            $posts = decode_json(
                $response->decoded_content(charset => 'utf-8'),
            );
            my $topics_ref = $posts->{topic_list}->{topics};
            die 'Community response did not include a topics array'
                unless ref $topics_ref eq 'ARRAY';

            my @topics = grep { !$_->{pinned} } @$topics_ref;
            splice @topics, 5;
            $posts = [
                map { { title => $_->{title}, slug => $_->{slug} } } @topics,
            ];
            $cache->set($key => $posts, $COMMUNITY_POSTS_CACHE_TIMEOUT);
        } catch {
            $self->c->log->error("Failed to parse community posts: $_");
            return undef;
        };
    }

    return $posts;
}

__PACKAGE__->meta->make_immutable;
1;
