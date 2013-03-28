use strict;
use warnings;
use Test::More;
use Test::Magpie::ArgumentMatcher qw( anything hash set );
use Test::Magpie qw( mock when inspect verify );
use Test::Routine;
use Test::Routine::Util;
use MusicBrainz::Server::Test;

use aliased 'MusicBrainz::Server::Entity::Subscription::Artist' => 'ArtistSubscription';
use aliased 'MusicBrainz::Server::Entity::Subscription::DeletedArtist' => 'DeletedArtistSubscription';
use aliased 'MusicBrainz::Server::Entity::Subscription::DeletedLabel' => 'DeletedLabelSubscription';
use aliased 'MusicBrainz::Server::Entity::Subscription::Label' => 'LabelSubscription';
use aliased 'MusicBrainz::Server::Entity::EditorSubscription';
use aliased 'MusicBrainz::Server::Edit';
use aliased 'MusicBrainz::Server::Entity::Editor';
use aliased 'MusicBrainz::Script::SubscriptionEmails' => 'Script';

use DateTime;
use MusicBrainz::Server::Constants qw( :edit_status );

my $c = MusicBrainz::Server::Test->create_test_context(
    models => {
        map { $_ => mock } qw( Artist Editor Edit EditorSubscriptions )
    }
);

has emailer => (
    is => 'ro',
    default => sub { mock },
    lazy => 1,
    clearer => 'clear_emailer'
);

has script => (
    is => 'ro',
    default => sub {
        my $test = shift;
        Script->new(
            c => $c, emailer => $test->emailer, verbose => 0, dry_run => 0
        );
    },
    lazy => 1,
    clearer => 'clear_script',
);

before run_test => sub {
    my $test = shift;
    $test->clear_emailer;
    $test->clear_script;
};

my $acid2 = Editor->new(
    name => 'aCiD2', id => 1,
    email => 'acid2@example.com',
    email_confirmation_date => DateTime->now
);

test 'Sending edits' => sub {
    my $test = shift;
    my $spor_subscription = ArtistSubscription->new( editor => $acid2, artist_id => 1, editor_id => $acid2->id,
                                                     last_edit_sent => 0 );
    my $open_edit         = Edit->new(status => $STATUS_OPEN, editor_id => 50 );
    my $applied_edit      = Edit->new(status => $STATUS_APPLIED, editor_id => 50 );

    mock_subscriptions(
        max_id => 10,
        editors => [ $acid2 ],
        subscriptions => {
            $acid2->id => [ $spor_subscription ],
        },
        edits => [
            [ $spor_subscription => [ $open_edit, $applied_edit ]]
        ]
    );

    $test->script->run;

    subtest 'sends email to aCiD2' => sub {
        my %args = inspect($test->emailer)
            ->send_subscriptions_digest(hash(editor => $acid2), anything)
                ->arguments;

        verify($c->model('Artist'))->load($spor_subscription);

        ok(%args, 'sends an email to aCiD2');
        delete $args{editor};
        is_deeply(\%args, {
            edits => {
                artist => [{
                    subscription => $spor_subscription,
                    open => [ $open_edit ],
                    applied => [ $applied_edit ]
                }]
            }
        }, 'notifies about 1 open edit to Spor');
    };

    subtest 'updates subscriptions' => sub {
        verify($c->model('EditorSubscriptions'))
            ->update_subscriptions(10, $acid2->id);
    };
};

test 'No edits means no email' => sub {
    my $test = shift;
    my $warp = Editor->new(
        name => 'warp', id => 2,
        email => 'warp@example.com',
        email_confirmation_date => DateTime->now
    );
    my $lady_gaga_subscription = ArtistSubscription->new( editor => $warp, artist_id => 1, editor_id => $warp->id,
                                                          last_edit_sent => 0 );

    mock_subscriptions(
        editors => [ $warp ],
        subscriptions => {
            $warp->id => [ $lady_gaga_subscription ]
        },
        edits => [ ]
    );

    $test->script->run;

    ok(!defined inspect($test->emailer)
        ->send_subscriptions_digest(anything),
        'did not send any emails');

};

test 'Handling deletes and merges' => sub {
    my $test = shift;

    my $label  = DeletedLabelSubscription->new(
        edit_id => 1,
        last_known_name => 'Revolution Records',
        last_known_comment => 'drum & bass',
        editor_id => $acid2->id,
        reason => 'merged'
    );

    my $artist = DeletedArtistSubscription->new(
        edit_id => 2,
        artist_id => 1,
        editor_id => $acid2->id,
        last_known_name => 'Nosaj Thing',
        last_known_comment => '',
        reason => 'deleted'
    );

    mock_subscriptions(
        editors => [ $acid2 ],
        subscriptions => {
            $acid2->id => [ $artist, $label ]
        }
    );

    $test->script->run;

    subtest 'Sent emails about merges and deletes' => sub {
        my %args = inspect($test->emailer)->send_subscriptions_digest(anything)
            ->arguments;

        is_deeply($args{deletes} => [
            $artist, $label
        ], 'has information about the deleted label and merged artist')
    };

    subtest 'Deleted deleted and merged subscriptions from the database' => sub {
        verify($c->model('EditorSubscriptions'))->update_subscriptions(anything);
    }
};

test 'Editor subscriptions' => sub {
    my $test = shift;
    my $editor          = Editor->new( id => 2 );
    my $editor_sub      = EditorSubscription->new( subscribed_editor_id => $editor->id, editor_id => $acid2->id,
                                                   last_edit_sent => 0 );
    my $self_editor_sub = EditorSubscription->new( subscribed_editor_id => $acid2->id,  editor_id => $acid2->id,
                                                   last_edit_sent => 0 );
    my $open_edit       = Edit->new( status => $STATUS_OPEN, editor_id => 50  );
    my $applied_edit    = Edit->new( status => $STATUS_APPLIED, editor_id => 50  );
    my $self_edit       = Edit->new( status => $STATUS_APPLIED, editor_id => $acid2->id  );

    mock_subscriptions(
        editors => [ $acid2 ],
        subscriptions => {
            $acid2->id => [ $editor_sub, $self_editor_sub ]
        },
        edits => [
            [ $editor_sub => [ $open_edit, $applied_edit ] ],
            [ $self_editor_sub => [ $self_edit ] ],
        ]
    );
    when($c->model('Editor'))->get_by_id($editor->id)->then_return($editor);
    when($c->model('Editor'))->get_by_id($acid2->id)->then_return($acid2);

    $test->script->run;

    subtest 'Sent emails about the edits made' => sub {
        my %args = inspect($test->emailer)->send_subscriptions_digest(anything)
            ->arguments;

        is_deeply($args{edits} => {
            editor => [{
                open => [ $open_edit ],
                applied => [ $applied_edit ],
                subscription => $editor_sub
            },
            {
                open => [ ],
                applied => [ $self_edit ],
                subscription => $self_editor_sub
            }]
        });
        is($editor_sub->subscribed_editor => $editor,
            'did load the editor');
        is($self_editor_sub->subscribed_editor => $acid2,
            'did load the editor');
    };

    subtest 'Loads the editor in question' => sub {
        verify($c->model('Editor'))->get_by_id($editor->id);
    }
};

test 'Does not send an editors own edits' => sub {
    my $test = shift;
    my $open_edit = Edit->new( status => $STATUS_OPEN, editor_id => 1 );
    my $artist_sub = ArtistSubscription->new( editor => $acid2, editor_id => 1, artist_id => 1,
                                              last_edit_sent => 0 );

    mock_subscriptions(
        editors => [ $acid2 ],
        subscriptions => {
            $acid2->id => [ $artist_sub ]
        },
        edits => [
            [ $artist_sub => [ $open_edit ] ]
        ]
    );

    $test->script->run;

    ok(!defined inspect($test->emailer)
        ->send_subscriptions_digest(anything),
        'did not send any emails');
};

run_me;
done_testing;

sub mock_subscriptions
{
    my %args = @_;

    when($c->model('Edit'))->get_max_id->then_return($args{max_id} || 1000);

    for (keys %{ $args{subscriptions} }) {
        when($c->model('EditorSubscriptions'))->get_all_subscriptions($_)
            ->then_return(@{ $args{subscriptions}->{$_} });
    }

    for (@{ $args{edits} }) {
        my ($subscription, $edits) = @{ $_ };
        when($c->model('Edit'))->find_for_subscription($subscription)
            ->then_return(@$edits);
    }

    when($c->model('Editor'))->editors_with_subscriptions
        ->then_return( @{ $args{editors} } );
}
