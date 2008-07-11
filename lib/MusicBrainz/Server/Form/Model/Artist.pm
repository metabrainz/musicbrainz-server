package MusicBrainz::Server::Form::Model::Artist;

use strict;
use warnings;

use MusicBrainz;
use MusicBrainz::Server::Artist;

use base 'Form::Processor';

sub init_item {
    my $self = shift;
    my $id = $self->item_id;

    return unless defined $id;

    my $mb = new MusicBrainz;
    $mb->Login();

    my $artist = MusicBrainz::Server::Artist->newFromId($mb->{DBH}, $id);

    return $artist;
}

sub init_value {
    my ($self, $field, $item) = @_;

    my $item ||= $self->item;
    
    use Switch;
    switch($field->name)
    {
        return $item->GetName case ('name');
        return $item->GetSortName case('sortname');
        return $item->GetType case('artist_type');
        return $item->GetBeginDate case('start');
        return $item->GetEndDate case('end');
    }
}

sub update_model {
}

sub update_from_form {

}

1;
