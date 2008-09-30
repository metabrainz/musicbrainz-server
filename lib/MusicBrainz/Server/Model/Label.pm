package MusicBrainz::Server::Model::Label;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use Carp;
use MusicBrainz::Server::Adapter 'LoadEntity';
use SearchEngine;

sub load
{
    my ($self, $id) = @_;

    my $label = MusicBrainz::Server::Label->new($self->dbh);
    LoadEntity($label, $id);

    return $label;
}

sub direct_search
{
    my ($self, $query) = @_;

    my $engine = new SearchEngine($self->context->mb->{DBH}, 'label');
    $engine->Search(query => $query, limit => 0);

    return undef
        unless $engine->Result != &SearchEngine::SEARCHRESULT_NOQUERY;

    my @labels;

    while(my $row = $engine->NextRow)
    {
        my $label = new MusicBrainz::Server::Label($self->context->mb->{DBH});

        $label->id($row->{labelid});
        $label->mbid($row->{labelgid});
        $label->label_code($row->{labelcode});
        $label->name($row->{labelname});
        $label->resolution($row->{labelresolution});

        push @labels, $label;
    }

    return \@labels;
}

1;
