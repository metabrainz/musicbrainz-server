package MusicBrainz::Server::Data::CritiqueBrainz;

use Moose;
use DateTime::Format::Natural;
use DBDefs;
use JSON;
use LWP::UserAgent;
use Text::Trim qw( trim );
use URI;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( encode_entities );
use aliased 'MusicBrainz::Server::Entity::CritiqueBrainz::Review';
use aliased 'MusicBrainz::Server::Entity::CritiqueBrainz::User';

with 'MusicBrainz::Server::Data::Role::Context';

sub load_review_extracts {
    my ($self, $release_group) = @_;

    my $url = URI->new(DBDefs->CRITIQUEBRAINZ_SERVER . '/ws/1/review/');
    my $gid = $release_group->gid;

    my %params = (
        release_group => $gid,
        offset => 0,
        limit => 1,
        sort => 'created'
    );

    $url->query_form(%params);

    my $content = $self->_get_review("$gid:most-recent", $url->as_string);
    return unless $content;

    $release_group->review_count($content->{count});
    $release_group->most_recent_review(_parse_review(@{ $content->{reviews} // [] }));

    if ($release_group->review_count > 1) {
        $params{sort} = 'rating';
        $url->query_form(%params);

        $content = $self->_get_review("$gid:most-popular", $url->as_string);
        return unless $content;

        $release_group->most_popular_review(_parse_review(@{ $content->{reviews} // [] }));
    }
}

sub _get_review {
    my ($self, $cache_suffix, $url) = @_;

    my $cache = $self->c->cache;
    my $cache_key = "cb:$cache_suffix";
    my $last_modified = $cache->get("$cache_key:last-modified");

    my $lwp = LWP::UserAgent->new;
    $lwp->env_proxy;
    $lwp->timeout(2);
    $lwp->agent(DBDefs->LWP_USER_AGENT);
    $lwp->default_header('If-Modified-Since' => $last_modified) if $last_modified;

    my $response = $lwp->get($url) or return;
    $response->is_success or return;

    my $content;
    if ($response->code == 304) {
        $content = $cache->get($cache_key);
    } else {
        $content = $response->content;
        $cache->set($cache_key, $content);

        $last_modified = $response->header('Last-Modified');
        $cache->set("$cache_key:last-modified", $last_modified) if $last_modified;
    }

    return decode_json($content);
}

sub _parse_review {
    my ($data) = @_;

    return undef unless $data;

    my $review = Review->new(
        id => $data->{id},
        created => DateTime::Format::Natural->new->parse_datetime($data->{created}),
        extract => encode_entities($data->{text}),
        author => User->new(id => $data->{user}{id}, name => $data->{user}{display_name})
    );

    # Elide long reviews to 500 characters, but if the total length is <= 750,
    # show the whole thing. This means the miniumum length of text to get cut off
    # is 250 chars, and there won't be situations where just one sentence or a
    # few words are missing.
    my $extract = $data->{text};

    if (length($extract) > 750) {
        my @words = split(/(?<=[\s\p{Punctuation}])/, $extract);
        my $i = 0;

        $extract = $words[$i++];
        return substr($extract, 0, 500) if length($extract) > 500;

        while ($i < @words && length($extract . $words[$i]) <= 500) {
            $extract .= $words[$i++];
        }

        $review->extract(
            l("{review}&#8230; {url|Read more &#187;}", {
                review => encode_entities(trim($extract)),
                url => $review->href
            })
        );
    }

    return $review;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
