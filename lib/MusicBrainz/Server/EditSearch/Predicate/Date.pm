package MusicBrainz::Server::EditSearch::Predicate::Date;
use Moose;
use namespace::autoclean;
use feature 'switch';

use DateTime::Format::Natural;
use DateTime::Format::Pg;

# Happens to share the same operators as ID searches, just handles the
# input slightly differently
extends 'MusicBrainz::Server::EditSearch::Predicate::ID';
with 'MusicBrainz::Server::EditSearch::Predicate';

sub transform_user_input {
    my ($self, $argument) = @_;
    my $parser = DateTime::Format::Natural->new;
    DateTime::Format::Pg->format_datetime($parser->parse_datetime($argument));
}
}

1;
