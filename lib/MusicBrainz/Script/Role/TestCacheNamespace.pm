package MusicBrainz::Script::Role::TestCacheNamespace;

use DBDefs;
use Moose::Role;

requires qw( database run );

around run => sub {
    my ($orig, $self, @args) = @_;

    if ($ENV{MUSICBRAINZ_RUNNING_TESTS}) {
        no warnings 'redefine';
        my $database = $self->database;
        *DBDefs::CACHE_NAMESPACE = sub { "MB:$database:" };
    }

    $self->$orig(@args);
};

no Moose::Role;
1;

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
