package t::Edit;
use Moose::Role;
use namespace::autoclean;

around run_test => sub {
    my $orig = shift;
    my $self = shift;

    $self->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
VALUES
  (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', 'foo@example.com', now()),
  (4, 'modbot', '{CLEARTEXT}pass', 'a359885742ca76a15d93724f1a205cc7', 'foo@example.com', now());
EOSQL

    $self->$orig(@_);
};

1;
