package MusicBrainz::Server::Translation::Languages;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Translation'; }

with 'MusicBrainz::Server::Role::Translation' => { domain => 'languages' };

sub l { __PACKAGE__->instance->gettext(@_) }
sub lp { __PACKAGE__->instance->pgettext(@_) }
sub ln { __PACKAGE__->instance->ngettext(@_) }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
