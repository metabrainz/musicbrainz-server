package MusicBrainz::Server::Form::Field::Comment;
use Moose;

extends 'MusicBrainz::Server::Form::Field::Text';

has '+maxlength' => ( default => 255 );
has '+not_nullable' => ( default => 1 );

1;
