package t::MusicBrainz::Server::EditRegistry;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use aliased 'MusicBrainz::Server::EditRegistry';

test 'All edits have distinct names' => sub {
    my @classes = EditRegistry->get_all_classes;
    my %seen_names;
    for my $class (@classes) {
        ok(!exists $seen_names{$class->edit_name},
           "$class has a distinct edit name");
    }
};

test 'All edits have an edit category' => sub {
    my @classes = EditRegistry->get_all_classes;
    # Grep to ignore any stuff in t::
    for my $class (grep /^MusicBrainz::/, @classes) {
        ok($class->edit_category,
           "$class has an edit category");
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
