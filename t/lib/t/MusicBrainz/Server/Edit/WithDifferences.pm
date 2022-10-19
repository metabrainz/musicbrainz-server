package t::MusicBrainz::Server::Edit::WithDifferences;
use strict;
use warnings;

use Test::Routine;
use Test::More;

{
    package t::MusicBrainz::Server::Edit::WithDifferences::Entity;
    use Moose;

    has 'foo_id' => (
        is => 'ro',
        isa => 'Int',
    );

    sub code { 'potatoes' }
};

{
    package t::MusicBrainz::Server::Edit::WithDifferences::TestEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit::WithDifferences';

    sub edit_name { 'Test Edit' }
    sub edit_type { 12345 }

    sub _mapping
    {
        return (
            foo => 'foo_id',
            bar => sub { shift->code }
        )
    }
};

test 'Check _change_hash' => sub {
    my $edit = t::MusicBrainz::Server::Edit::WithDifferences::TestEdit->new;
    my $instance = t::MusicBrainz::Server::Edit::WithDifferences::Entity->new(foo_id => 5);
    is_deeply($edit->_change_hash($instance, qw( foo bar )), { foo => 5, bar => 'potatoes' });

};

1;
