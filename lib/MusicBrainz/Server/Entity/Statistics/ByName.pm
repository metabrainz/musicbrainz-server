package MusicBrainz::Server::Entity::Statistics::ByName;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Map );

has data => (
    is => 'rw',
    isa => Map[ Str, Int ], # Map date to value
    traits => [ 'Hash' ],
    default => sub { {} },
    handles => {
        statistic_for => 'get'
    }
);

has name => (
   is => 'rw',
   isa => 'Str'
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
