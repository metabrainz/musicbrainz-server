package MusicBrainz::Server::Plugin::Compare;

use strict;
use warnings;

use Data::Compare qw( Compare );

use base 'Template::Plugin';

sub preferences { shift->{preferences}; }

sub new {
    my ($class) = @_;
    return bless { }, $class;
}

sub compare {
    my ($self, $a, $b) = @_;
    return Compare($a, $b);
}

1;
