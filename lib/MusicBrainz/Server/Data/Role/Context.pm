package MusicBrainz::Server::Data::Role::Context;
use Moose::Role;

has 'c' => (
    is => 'rw',
    isa => 'Object',
    weak_ref => 1,
    handles => [ 'store' ]
);

no Moose::Role;
1;

=head1 NAME

MusicBrainz::Server::Data::Role::Context

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
