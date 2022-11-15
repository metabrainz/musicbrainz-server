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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
