package MusicBrainz::Server::Edit::Medium;
use List::AllUtils qw( any );
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Medium') }

sub check_tracks_against_format {
    my ($self, $tracklist, $format_id) = @_;

    my @tracklist = @{ $tracklist // [] };

    return unless $format_id;
    return unless any { $_->{is_data_track} } @tracklist;

    my $format = $self->c->model('MediumFormat')->get_by_id($format_id);
    die 'Format does not support pregap or data tracks' unless $format->has_discids;

    my $data_tracks_started;
    for (@tracklist) {
        if ($_->{is_data_track}) {
            $data_tracks_started = 1;
        } elsif ($data_tracks_started) {
            die 'All data tracks must be contiguous at the end of the medium';
        }
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
