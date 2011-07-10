package t::Edit;
use Moose::Role;
use namespace::autoclean;

around run_test => sub {
    my $orig = shift;
    my $self = shift;

    $self->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'pass');
INSERT INTO editor (id, name, password) VALUES (4, 'modbot', 'pass');
EOSQL

    $self->$orig(@_);
};

1;
