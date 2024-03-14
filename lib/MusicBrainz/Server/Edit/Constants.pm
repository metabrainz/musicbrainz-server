package MusicBrainz::Server::Edit::Constants;
use strict;
use warnings;

use base 'Exporter';
use Readonly;

use MusicBrainz::Server::Translation qw( N_lp );

our @EXPORT_OK = qw(
    %EDIT_KIND_LABELS
);

Readonly our %EDIT_KIND_LABELS => (
    'add' => N_lp('Add', 'edit kind'),
    'edit' => N_lp('Edit', 'edit kind'),
    'merge' => N_lp('Merge', 'edit kind'),
    'other' => N_lp('Other', 'edit kind'),
    'remove' => N_lp('Remove', 'edit kind'),
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
