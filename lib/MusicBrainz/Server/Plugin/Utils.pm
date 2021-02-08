package MusicBrainz::Server::Plugin::Utils;

use strict;
use warnings;

use base 'Template::Plugin';

sub new
{
    my ($class, $context) = @_;
    return bless {
        ctx => $context,
    }, $class;
}

sub filter
{
    my ($self, $variable, $name) = @_;

    my $filter = $self->{ctx}->filter($name);
    return $filter->($variable);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
