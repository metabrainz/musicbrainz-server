package t::MusicBrainz::Server::Entity::Editor;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

BEGIN { use MusicBrainz::Server::Entity::Editor };

use DateTime;

test all => sub {

my $editor = MusicBrainz::Server::Entity::Editor->new;
ok(defined $editor, 'new did not construct anything');
isa_ok($editor, 'MusicBrainz::Server::Entity::Editor', 'isa');

# Main attributes
can_ok($editor, qw( name password privileges email biography website
                    registration_date last_login_date has_ten_accepted_edits
                    email_confirmation_date ));

# Check privileges
my @privilege_helpers = qw( is_auto_editor is_mbid_submitter is_bot
                            is_wiki_transcluder is_untrusted is_relationship_editor
                            is_account_admin );
can_ok($editor, @privilege_helpers);

ok(!$editor->$_, "$_ should be false") for @privilege_helpers;
$editor->privileges(255);
ok($editor->$_, "$_ should be true") for @privilege_helpers;

# Email address helpers
$editor->email('foo@bar.org');
ok($editor->has_email_address, 'should have email address');
ok(!$editor->has_confirmed_email_address, 'email address should not be confirmed');

$editor->email_confirmation_date(DateTime->now);
ok($editor->has_confirmed_email_address, 'should be confirmed');

$editor->registration_date(DateTime->now);
ok($editor->is_newbie);

$editor->registration_date(DateTime->new(year => '1980'));
ok(!$editor->is_newbie, 'shouldnt be a newbie');

};

1;
