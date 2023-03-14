package MusicBrainz::Server::EditSearch::Predicate::URL;
use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Validation qw( is_valid_url );

with 'MusicBrainz::Server::EditSearch::Predicate';

has name => (
    is => 'ro',
    isa => 'Str'
);

sub operator_cardinality_map {
    return (
        '=' => undef,
        '!=' => undef,
    );
};

sub valid {
    my $self = shift;
    my @args = @{ $self->sql_arguments };
    return @args && is_valid_url($args[0]);
}

sub combine_with_query {
    my ($self, $query) = @_;

    $query->add_where([
        ($self->operator eq '!=' ? 'NOT ' : '') .
        'EXISTS (SELECT 1 FROM edit_url JOIN url ON edit_url.url = url.id WHERE edit = edit.id AND url.url = ?)', $self->sql_arguments
    ]);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
