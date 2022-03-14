package MusicBrainz::Server::ControllerUtils::JSON;

use base 'Exporter';

our @EXPORT_OK = qw(
    serialize_pager
);

sub serialize_pager {
    my ($pager) = @_;

    return {
        current_page => $pager->current_page + 0,
        entries_per_page => $pager->entries_per_page + 0,
        first_page => 1,
        last_page => $pager->last_page + 0,
        next_page => defined $pager->next_page ? $pager->next_page + 0 : undef,
        previous_page => defined $pager->previous_page ? $pager->previous_page + 0 : undef,
        total_entries => $pager->total_entries + 0,
    };
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
