package MusicBrainz::Server::Controller::Role::Rating;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

sub ratings : Chained('load') PathPart('ratings')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{$self->{entity_name}};
    my @ratings = $c->model($self->{model})->rating->find_by_entity_id($entity->id);
    $c->model('Editor')->load(@ratings);
    $c->model('Editor')->load_preferences(map { $_->editor } @ratings);

    my @public_ratings;
    my $private_rating_count = 0;

    for my $rating (@ratings) {
        if ($rating->editor->preferences->public_ratings) {
            push @public_ratings, $rating;
        } else {
            $private_rating_count++;
        }
    }

    my %props = (
        entity => $entity,
        publicRatings => \@public_ratings,
        privateRatingCount => $private_rating_count,
    );

    $c->stash(
        component_path => 'entity/Ratings',
        component_props => \%props,
        current_view => 'Node',
    );
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
