package MusicBrainz::Server::EditSearch::Predicate::URL;
use Moose;
use namespace::autoclean;
use Scalar::Util qw( looks_like_number );

# Should be replaced with a usual Entity predicate when URL is properly searchable (MBS-12122)

with 'MusicBrainz::Server::EditSearch::Predicate';

has name => (
    is => 'ro',
    isa => 'Str'
);

has id => (
    is => 'ro'
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
    return @args && looks_like_number($args[0]);
}

sub combine_with_query {
    my ($self, $query) = @_;

    $query->add_where([
        ($self->operator eq '!=' ? 'NOT ' : '') .
        'EXISTS (SELECT 1 FROM edit_url WHERE edit = edit.id AND url = ?)', $self->sql_arguments
    ]);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
