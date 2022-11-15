package MusicBrainz::Script::Role::Context;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Context;

has 'c' => (
    isa        => 'MusicBrainz::Server::Context',
    is         => 'ro',
    traits     => [ 'NoGetopt' ],
    lazy_build => 1,
    handles    => [qw( sql )]
);

sub _build_c
{
    return MusicBrainz::Server::Context->create_script_context;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
