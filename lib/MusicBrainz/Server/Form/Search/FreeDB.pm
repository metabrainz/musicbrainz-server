package MusicBrainz::Server::Form::Search::FreeDB;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'freedb' );

has_field 'discid' => (
    type => 'Text',
    required => 1
);

has_field category => (
    type => 'Select',
    required => 1
);

sub options_category {
    my $self = shift;
    return [
        map { $_ => $_ }
            qw( blues classical country data folk jazz newage reggae rock soundtrack misc )
    ]
}

1;
