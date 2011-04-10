package t::MusicBrainz::Server::EditRegistry;
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
    for my $class (@classes) {
        ok($class->edit_category,
           "$class has an edit category");
    }
};

1;
