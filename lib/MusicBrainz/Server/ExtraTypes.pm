package MusicBrainz::Server::ExtraTypes;

use MooseX::Types -declare => [qw( DateTime )];
use MooseX::Types::Moose qw( Str );
use DateTime::Format::Pg;

class_type DateTime, { class => 'DateTime' };

coerce DateTime, from Str,
    via { DateTime::Format::Pg->parse_datetime($_) };

1;
