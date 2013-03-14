use strict;
use warnings;

use Authen::Passphrase::BlowfishCrypt;
use Authen::Passphrase::RejectAll;
use MusicBrainz::Server::Context;
use Sql;
use Try::Tiny;

$| = 1;

my $c = MusicBrainz::Server::Context->create_script_context;

printf "Hashing passwords\n";
while (1) {
    if (my $batch_id = $c->sql->select_single_value('SELECT pgq.next_batch(?, ?)', 'EditorChanges', 'PasswordHasher')) {
        my @events = @{ $c->sql->select_list_of_hashes('SELECT * FROM pgq.get_batch_events(?)', $batch_id) };

        my $i = 0;
        for my $event (@events) {
            my $name = $event->{ev_data};
            try {
                Sql::run_in_transaction(sub {
                    $c->sql->do('SET TRANSACTION ISOLATION LEVEL SERIALIZABLE');
                    my $current_password = $c->sql->select_single_value('SELECT password FROM editor WHERE name = ?', $name);

                    my $authenticator = defined($current_password) && $current_password != ''
                        ? Authen::Passphrase::BlowfishCrypt->new(
                            salt_random => 1,
                            cost => 8,
                            passphrase => $current_password
                          )
                            : Authen::Passphrase::RejectAll->new;

                    $c->sql->do(
                        'UPDATE editor SET bcrypt_password = ? WHERE name = ?',
                        $authenticator->as_rfc2307,
                        $name
                    );
                }, $c->sql);

                printf "Hashed passwords: %d/%d\r", $i++, scalar(@events);
            }
            catch {
                printf STDERR "Could not hash password for '$name'\n";
                $c->sql->auto_commit(1);
                $c->sql->do('SELECT pgq.event_failed(?, ?, ?)', $batch_id, $event->{ev_id}, $_);
            };
            printf "Hashed passwords: %d/%d\n", scalar(@events), scalar(@events);
        }

        $c->sql->auto_commit(1);
        $c->sql->do('SELECT pgq.finish_batch(?)', $batch_id);
    }

    printf "No events to process\n";
    sleep 10;
}
