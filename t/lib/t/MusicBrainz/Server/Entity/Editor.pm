package t::MusicBrainz::Server::Entity::Editor;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

BEGIN { use MusicBrainz::Server::Entity::Editor };

use DateTime;

=head1 DESCRIPTION

This test checks editor privileges, mail status variables, and whether
editors are correctly marked as newbies and/or beginners.

=cut

test 'Basic Moose test' => sub {
    my $editor = MusicBrainz::Server::Entity::Editor->new(id => 42);
    ok(defined $editor, 'Constructor returns defined editor');
    isa_ok($editor, 'MusicBrainz::Server::Entity::Editor');

    # Main attributes
    can_ok($editor, qw( name password privileges email biography website
                        registration_date last_login_date
                        has_ten_accepted_edits email_confirmation_date ));
};

test 'Editor privileges' => sub {
    my $editor = MusicBrainz::Server::Entity::Editor->new(id => 42);

    my @positive_priv_checks = qw( is_auto_editor is_mbid_submitter is_bot
                                   is_wiki_transcluder is_relationship_editor
                                   is_account_admin is_nag_free
                                   is_location_editor is_banner_editor );
    my @negative_priv_checks = qw( is_editing_disabled is_spammer
                                   is_adding_notes_disabled is_untrusted);

    my @all_priv_checks = (@positive_priv_checks, @negative_priv_checks);

    note('Ensure all privilege checks are available');
    can_ok($editor, @all_priv_checks);

    note('Ensure all privileges are off by default');
    ok(!$editor->$_, "$_ should be false") for @all_priv_checks;

    note('We set full positive privileges for the editor');
    $editor->privileges(1019);
    ok($editor->$_, "$_ should be true") for @positive_priv_checks;
    ok(!$editor->$_, "$_ should be false") for @negative_priv_checks;

    note('We set full negative privileges for the editor');
    $editor->privileges(7172);
    ok(!$editor->$_, "$_ should be false") for @positive_priv_checks;
    ok($editor->$_, "$_ should be true") for @negative_priv_checks;

    note('We set the whole set of privileges for the editor');
    $editor->privileges(8191);
    ok($editor->$_, "$_ should be true") for @all_priv_checks;
};

test 'Editor mail status' => sub {
    my $editor = MusicBrainz::Server::Entity::Editor->new(id => 42);

    ok(
        !$editor->has_email_address,
        'The check for an email address returns false when none has been set',
    );

    note('We set an email for the editor');
    $editor->email('foo@bar.org');
    ok(
        $editor->has_email_address,
        'The check for an email address returns true',
    );
    ok(
        !$editor->has_confirmed_email_address,
        'The check for email confirmation returns false',
    );

    note('We set an email confirmation date for the editor');
    $editor->email_confirmation_date(DateTime->now);
    ok(
        $editor->has_confirmed_email_address,
        'The check for email confirmation returns true',
    );
};

test 'Newbie and beginner editors' => sub {
    my $editor = MusicBrainz::Server::Entity::Editor->new(id => 42);

    note('We set a registration date of just now');
    $editor->registration_date(DateTime->now);
    ok($editor->is_newbie, 'The editor is marked as a newbie');
    ok($editor->is_limited, 'The editor is marked as a beginner');

    note('We set a registration date of 1980');
    $editor->registration_date(DateTime->new(year => '1980'));
    ok(!$editor->is_newbie, 'The editor is no longer marked as a newbie');
    ok($editor->is_limited, 'The editor is still marked as a beginner');

    note('We set an email and confirmation date for the editor');
    $editor->email('foo@bar.org');
    $editor->email_confirmation_date(DateTime->now);
    ok($editor->is_limited, 'The editor is still marked as a beginner');

    note('We claim the editor has ten accepted edits');
    $editor->has_ten_accepted_edits(1);
    ok(!$editor->is_limited, 'The editor is no longer marked as a beginner');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
