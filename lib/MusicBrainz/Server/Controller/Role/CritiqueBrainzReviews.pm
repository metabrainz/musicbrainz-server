package MusicBrainz::Server::Controller::Role::CritiqueBrainzReviews;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use List::AllUtils qw( rev_nsort_by );
use namespace::autoclean;

sub critiquebrainz_review_count : Chained('load') PathPart('critiquebrainz-review-count')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{entity};
    $c->model('CritiqueBrainz')->load_review_count($entity);

    $c->res->headers->header('X-Robots-Tag' => 'noindex');
    $c->res->content_type('application/json; charset=utf-8');
    $c->res->{body} = $c->json_utf8->encode({
        reviewCount => $entity->review_count,
    });
}

sub critiquebrainz_reviews : Chained('load') PathPart('critiquebrainz-reviews')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{entity};
    $c->model('CritiqueBrainz')->load_display_reviews($entity);

    $c->res->headers->header('X-Robots-Tag' => 'noindex');
    $c->res->content_type('application/json; charset=utf-8');
    $c->res->{body} = $c->json_utf8->encode({
        mostPopularReview => $entity->most_popular_review,
        mostRecentReview => $entity->most_recent_review,
        reviewCount => $entity->review_count,
    });
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
