use strict;
use warnings;
use Test::More;
use Test::Magpie::ArgumentMatcher qw( anything hash );
use Test::Magpie qw( mock when inspect verify );
use MusicBrainz::Server::Test;

use aliased 'MusicBrainz::Server::Entity::ArtistSubscription';
use aliased 'MusicBrainz::Server::Edit';
use aliased 'MusicBrainz::Server::Entity::Editor';
use aliased 'MusicBrainz::Script::SubscriptionEmails' => 'Script';

use DateTime;
use MusicBrainz::Server::Types qw( :edit_status );

my $c = MusicBrainz::Server::Test->create_test_context(
    models => {
        Editor => mock,
        Edit => mock,
        EditorSubscriptions => mock
    }
);

subtest 'Sending edits' => sub {
    my $emailer = mock;
    my $acid2 = Editor->new(
        name => 'aCiD2', id => 1,
        email => 'acid2@example.com',
        email_confirmation_date => DateTime->now
    );
    my $spor_subscription = ArtistSubscription->new( editor => $acid2 );
    my $open_edit = Edit->new(status => $STATUS_OPEN);
    my $applied_edit = Edit->new(status => $STATUS_APPLIED);

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

    my $script = Script->new(
        c => $c,
        emailer => $emailer,
        verbose => 0,
        dry_run => 0
    );
    $script->run;

    subtest 'sends email to aCiD2' => sub {
        my %args = inspect($emailer)
            ->send_subscriptions_digest(hash(to => $acid2), anything)
                ->arguments;

        ok(%args, 'sends an email to aCiD2');
        delete $args{to};
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

subtest 'No edits means no email' => sub {
    my $emailer = mock;
    my $warp = Editor->new(
        name => 'warp', id => 2,
        email => 'warp@example.com',
        email_confirmation_date => DateTime->now
    );
    my $lady_gaga_subscription = ArtistSubscription->new( editor => $warp );

    mock_subscriptions(
        max_id => 10,
        editors => [ $warp ],
        subscriptions => {
            $warp->id => [ $lady_gaga_subscription ]
        },
        edits => [ ]
    );

    my $script = Script->new(
        c => $c,
        emailer => $emailer,
        verbose => 0,
        dry_run => 0
    );
    $script->run;

    ok(!defined inspect($emailer)
        ->send_subscriptions_digest(anything),
        'did not send any emails');

};

done_testing;

sub mock_subscriptions
{
    my %args = @_;

    when($c->model('Edit'))->get_max_id->then_return($args{max_id});

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
