package MusicBrainz::Server::Form::Field::Barcode;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Validation;

extends 'HTML::FormHandler::Field::Text';

apply ([
   { check => sub { MusicBrainz::Server::Validation::IsValidEAN(shift) },
     message => 'This is not a valid barcode',
   }
]);

1;
