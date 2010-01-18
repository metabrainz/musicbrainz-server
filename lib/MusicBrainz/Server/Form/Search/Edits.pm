package MusicBrainz::Server::Form::Search::Edits;
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
    my @types = MusicBrainz::Server::EditRegistry->get_all_classes;
    return [
        _sort_hash_value(map {
            Class::MOP::load_class($_);
            $_->edit_type => $_->edit_name;
        } @types)
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
