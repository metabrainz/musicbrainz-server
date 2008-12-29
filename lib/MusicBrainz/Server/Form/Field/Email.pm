package MusicBrainz::Server::Form::Field::Email;

use strict;
use warnings;

use base 'Form::Processor::Field::Email';

# Form::Processor::Field does not define a default size.
# 0 lets forms/widgets/text.tt specify a default that does
# not only handle email fields.
sub size { 0 }

1;
