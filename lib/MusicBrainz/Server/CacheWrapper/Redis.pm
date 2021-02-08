package MusicBrainz::Server::CacheWrapper::Redis;

use Moose;
use Storable qw( nfreeze thaw );

extends 'MusicBrainz::Redis';

sub _encode_value { nfreeze(\$_[1]) }

sub _decode_value { ${thaw($_[1])} }

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
