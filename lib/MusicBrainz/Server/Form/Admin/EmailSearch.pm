package MusicBrainz::Server::Form::Admin::EmailSearch;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => (default => 'emailsearch');

has_field 'email' => (type => 'Text');
has_field 'submit' => (type => 'Submit');

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
