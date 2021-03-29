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
  (200, 'editor200', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', 'foo2@example.com', now());
EOSQL

    $self->$orig(@_);
};

1;
