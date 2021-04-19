package MusicBrainz::Server::Data::CritiqueBrainz;

use Moose;
use DBDefs;
use HTTP::Date qw( str2time );
use JSON;
use Text::Markdown qw( markdown );
use Text::Trim qw( trim );
use URI;
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( encode_entities );
use aliased 'MusicBrainz::Server::Entity::CritiqueBrainz::Review';
use aliased 'MusicBrainz::Server::Entity::CritiqueBrainz::User';

with 'MusicBrainz::Server::Data::Role::Context';

sub load_display_reviews {
    my ($self, $release_group) = @_;

    my $url = URI->new(DBDefs->CRITIQUEBRAINZ_SERVER . '/ws/1/review/');

    my %params = (
        release_group => $release_group->gid,
        offset => 0,
        limit => 1,
        sort => 'published_on'
    );

    $url->query_form(%params);

    my $content = $self->_get_review($url->as_string);
    return unless $content;

    $release_group->review_count($content->{count});
    $release_group->most_recent_review(_parse_review(@{ $content->{reviews} // [] }));

    if ($release_group->review_count > 1) {
        $params{sort} = 'rating';
        $url->query_form(%params);

        $content = $self->_get_review($url->as_string);
        return unless $content;

        $release_group->most_popular_review(_parse_review(@{ $content->{reviews} // [] }));
    }
}

sub _get_review {
    my ($self, $url) = @_;

    my $response = $self->c->lwp->get($url) or return;
    $response->is_success or return;

    my $review = eval { decode_json($response->content) };
    return $review;
}

sub _parse_review {
    my ($data) = @_;

    return undef unless $data;

    return Review->new(
        id => $data->{id},
        created => DateTime->from_epoch(epoch => str2time($data->{created})),
        body => non_empty($data->{text}) ? markdown($data->{text}) : '',
        author => User->new(id => $data->{user}{id}, name => $data->{user}{display_name})
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
