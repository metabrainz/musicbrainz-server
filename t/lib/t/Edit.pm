package t::Edit;
use Moose::Role;
use namespace::autoclean;

around run_test => sub {
    my $orig = shift;
    my $self = shift;

    $self->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834');
INSERT INTO editor (id, name, password, ha1) VALUES (4, 'modbot', '{CLEARTEXT}pass', 'a359885742ca76a15d93724f1a205cc7');
EOSQL

    $self->$orig(@_);
};

1;
