package t::MusicBrainz::Server::Data::Role::Merge;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Fatal;

{
    package t::MusicBrainz::Server::Data::Role::Merge::Impl;
    use Moose;
    use namespace::autoclean;

    with 'MusicBrainz::Server::Data::Role::Merge';

    sub _merge_impl {
        return 'Merge succeeded';
    }
}

has data_object => (
    is => 'ro',
    lazy => 1,
    clearer => '_clear_data_object',
    default => sub { t::MusicBrainz::Server::Data::Role::Merge::Impl->new }
);

before run_test => sub { shift->_clear_data_object };

test 'Cannot merge into nothing' => sub {
    my $test = shift;
    ok exception { $test->data_object->merge(undef, 1, 2, 3) };
};

test 'Must specify what to merge' => sub {
    my $test = shift;
    ok exception { $test->data_object->merge(1) };
};

test 'Cannot merge into self' => sub {
    my $test = shift;
    ok exception { $test->data_object->merge(1, 1, 2) };
};

1;
