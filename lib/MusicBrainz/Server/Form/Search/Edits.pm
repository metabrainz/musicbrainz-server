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
        map {
            Class::MOP::load_class($_);
            $_->edit_type => $_->edit_name;
        } @types
    ];
}

sub options_status
{
    return [
        status_names()
    ];
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
