package MusicBrainz::Server::Edit::Historic::NoSerialization;
use Moose::Role;

around 'deserialize_previous_value' => sub {
    my $orig = shift;
    my ($self, $previous) = @_;

    return $previous;
};

around 'deserialize_new_value' => sub {
    my $orig = shift;
    my ($self, $new) = @_;

    return $new;
};

no Moose::Role;
1;

