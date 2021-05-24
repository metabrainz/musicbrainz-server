package MusicBrainz::Server::Form::Field::Artist;
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Field::Compound';

has_field 'name' => ( type => 'Text' );
has_field 'id'   => ( type => '+MusicBrainz::Server::Form::Field::Integer' );

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
