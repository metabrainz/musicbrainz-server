package MusicBrainz::Data::TreeValidator::Transformations;

use strict;
use warnings;
use Text::Trim qw( trim );

use Sub::Exporter -setup => {
    exports => [ qw( collapse_whitespace ) ]
};

sub collapse_whitespace { \&_collapse_whitespace }
sub _collapse_whitespace { 
    local $_ = shift;

    s/\s+/ /;

    return trim ($_);
}

1;
