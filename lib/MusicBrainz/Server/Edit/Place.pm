package MusicBrainz::Server::Edit::Place;
use List::AllUtils qw( any );
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Place') }

sub _possible_duplicate_area {
    my ($self, $area_id, @possible_duplicates) = @_;

    # A comment is not required if the name is unique.
    return 0 unless @possible_duplicates;

    # We require a disambiguation comment if no area is given, or if there
    # is a possible duplicate in the same area or lacking area information.
    return 1 unless defined $area_id;

    return any {(!defined($_) || $_ == $area_id) ? 1 : 0} @possible_duplicates;
}

1;
