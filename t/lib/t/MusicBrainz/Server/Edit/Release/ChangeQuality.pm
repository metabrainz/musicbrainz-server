package t::MusicBrainz::Server::Edit::Release::ChangeQuality;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Release::ChangeQuality };

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_CHANGE_QUALITY );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_release');

# Starting point for releases
my $release = $c->model('Release')->get_by_id(1);
is_unchanged($release);
is($release->edits_pending, 0);

# Test editing all possible fields
my $edit = create_edit($c, $release);
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::ChangeQuality');

my ($edits) = $c->model('Edit')->find({ release => $release->id }, 10, 0);
is($edits->[0]->id, $edit->id);

$release = $c->model('Release')->get_by_id(1);
is($release->edits_pending, 1);
is_unchanged($release);

reject_edit($c, $edit);
$release = $c->model('Release')->get_by_id(1);
is_unchanged($release);
is($release->edits_pending, 0);

# Accept the edit
$edit = create_edit($c, $release);
accept_edit($c, $edit);

$release = $c->model('Release')->get_by_id(1);
is($release->quality, 2);
is($release->edits_pending, 0);

};

sub is_unchanged {
    my ($release) = @_;
    is($release->quality, 1);
}

sub create_edit {
    my $c = shift;
    my $release = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_RELEASE_CHANGE_QUALITY,
        editor_id => 1,
        to_edit   => $release,
        quality   => 2,
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
