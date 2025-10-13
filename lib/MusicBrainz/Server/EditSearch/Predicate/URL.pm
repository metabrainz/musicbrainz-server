package MusicBrainz::Server::EditSearch::Predicate::URL;
use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Validation qw( is_valid_url );

with 'MusicBrainz::Server::EditSearch::Predicate';

has name => (
    is => 'ro',
    isa => 'Str',
);

sub operator_cardinality_map {
    return (
        '=' => undef,
        '!=' => undef,
        '~' => undef,
        '!~' => undef,
    );
}

sub valid {
    my $self = shift;
    my @args = @{ $self->sql_arguments };
    if ($self->operator eq '=' || $self->operator eq '!=') {
        return @args && is_valid_url($args[0]);
    }
    return @args && non_empty($args[0]);
}

sub combine_with_query {
    my ($self, $query) = @_;

    my $negation = ($self->operator eq '!=' || $self->operator eq '!~') ? 'NOT ' : '';
    my $operator = ($self->operator eq '~' || $self->operator eq '!~') ? '~' : '=';
    $query->add_where([
        $negation .
        "EXISTS (SELECT 1 FROM edit_url JOIN url ON edit_url.url = url.id WHERE edit = edit.id AND url.url $operator ?)", $self->sql_arguments,
    ]);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
