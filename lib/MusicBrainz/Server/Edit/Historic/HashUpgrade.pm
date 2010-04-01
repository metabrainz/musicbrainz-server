package MusicBrainz::Server::Edit::Historic::HashUpgrade;
use MooseX::Role::Parameterized;

parameter 'value_mapping' => (
    isa => 'HashRef',
);

parameter 'key_mapping' => (
    isa => 'HashRef',
);

role {
    my $params = shift;

    method 'upgrade_attribute' => sub {
        my ($self, $key, $value) = @_;

        my $attribute = $params->key_mapping->{$key} or return ();
        my $inflator  = $params->value_mapping->{$attribute};

        $value = defined $inflator
            ? $inflator->($value)
                : $value eq '' ? undef : $value;

        return ($attribute => $value);
    };

    method 'upgrade_hash' => sub {
        my ($self, $hash) = @_;
        return {
            map {
                $self->upgrade_attribute($_, $hash->{$_});
            } keys %$hash
        };
    };
};

1;
