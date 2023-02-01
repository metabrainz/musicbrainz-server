package MusicBrainz::Server::Form::Search::Edits;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Edit::Utils qw( status_names );
use MusicBrainz::Server::EditRegistry;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'search-edits' );

has_field 'type' => (
    type => 'Multiple',
);

has_field 'status' => (
    type => 'Multiple'
);

sub options_type
{
    my $self = shift;
    my %grouped = MusicBrainz::Server::EditRegistry->grouped_by_name;
    return [
        _sort_hash_value(map {
            # edit types => edit name
            join(q(,), map { $_->edit_type } @{ $grouped{$_} }) => $_
        } keys %grouped)
    ];
}

sub options_status
{
    return [
        _sort_hash_value(status_names())
    ];
}

sub _sort_hash_value
{
    my %hash = @_;
    return map { $_ => $hash{$_} } sort { $hash{$a} cmp $hash{$b} } keys %hash;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
