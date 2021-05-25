package MusicBrainz::Server::Form::Field::Area;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Field::Compound';

has_field 'name' => ( type => 'Text' );
has_field 'gid' => ( type => '+MusicBrainz::Server::Form::Field::GID' );

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;

