package MusicBrainz::Server::Edit::Medium;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Medium') }

sub check_pregap_against_format {
    my ($self, $tracklist, $format_id) = @_;

    return unless $format_id;
    return unless @{ $tracklist // [] } && $tracklist->[0]->position == 0;

    my $format = $self->c->model('MediumFormat')->get_by_id($format_id);
    die "Format does not support pregap tracks" unless $format->has_discids;
}

1;
