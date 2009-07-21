package MusicBrainz::Server::Form::Field::Barcode;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Validation;

extends 'HTML::FormHandler::Field::Text';

=pod

This validation routine is currently too strict, so it has been disabled for
now. FIXME!

apply ([
   { check => sub { MusicBrainz::Server::Validation::IsValidEAN(shift) },
     message => 'This is not a valid barcode',
   }
]);

=cut

1;
