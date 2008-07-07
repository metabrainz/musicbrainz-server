package MusicBrainz::Server::Form::Model::UserPreference;

use strict;
use warnings;

use MusicBrainz;
use UserStuff;

use base 'Form::Processor';

sub init_item {
    my $self = shift;
    my $id = $self->item_id;

    return unless defined $id;

    my $mb = new MusicBrainz;
    $mb->Login();

    my $us = new UserStuff($mb->{DBH});
    return $us->newFromName($id);
}

sub init_value {
    my ($self, $field, $item) = @_;
    $item ||= $self->item;

    my $mb = new MusicBrainz;
    $mb->Login();

    $self->item->{DBH} = $mb->{DBH};

    return UserPreference::get_for_user($field->name, $item);
}

1;
