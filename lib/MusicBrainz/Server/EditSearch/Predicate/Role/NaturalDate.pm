package MusicBrainz::Server::EditSearch::Predicate::Role::NaturalDate;
use Moose::Role;
use namespace::autoclean;

use DateTime::Format::Natural;
use DateTime::Format::Pg;

with 'MusicBrainz::Server::EditSearch::Predicate';

sub operator_cardinality_map {
    return (
        BETWEEN => '2',
        map { $_ => 1 } qw( = < > >= <= != ),
    );
}

sub transform_user_input {
    my ($self, $argument) = @_;
    my $parser = DateTime::Format::Natural->new;
    DateTime::Format::Pg->format_datetime($parser->parse_datetime($argument));
}

sub valid {
    my ($self) = @_;
    my $parser = DateTime::Format::Natural->new;
    for my $arg_index (1.. $self->operator_cardinality($self->operator)) {
        my $arg = $self->argument($arg_index - 1) or return;
        $parser->parse_datetime($arg);
        $parser->success or return;
    }
    return 1;
}

1;
