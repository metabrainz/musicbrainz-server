package MusicBrainz::Server::Form::Merge::Release;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form::Merge';

has_field 'merge_strategy' => (
    type => 'Select',
    required => 1
);

sub edit_field_names { return ('merge_strategy') }

sub options_merge_strategy {
    return [
        $MusicBrainz::Server::Data::Release::MERGE_APPEND, l('Append mediums to target release'),
        $MusicBrainz::Server::Data::Release::MERGE_MERGE, l('Merge mediums and recordings')
    ]
}

1;
