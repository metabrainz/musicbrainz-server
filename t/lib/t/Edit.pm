package t::Edit;
use Moose::Role;
use namespace::autoclean;

around run_test => sub {
    my $orig = shift;
    my $self = shift;

    $self->c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', 'foo@example.com', now()),
                   (200, 'editor200', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', 'foo2@example.com', now());
        SQL

    $self->$orig(@_);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
