package MusicBrainz::Server::Report::LimitedEditors;
use Moose;

use MusicBrainz::Server::Constants qw( $BEGINNER_FLAG );

with 'MusicBrainz::Server::Report::EditorReport';

sub query { "
SELECT id,
       row_number() OVER (ORDER BY id DESC)
  FROM editor eor
 WHERE (privs & $BEGINNER_FLAG) > 0";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
