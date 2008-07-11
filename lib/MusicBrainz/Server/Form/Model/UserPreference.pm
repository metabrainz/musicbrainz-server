package MusicBrainz::Server::Form::Model::UserPreference;

use strict;
use warnings;

use MusicBrainz;
use UserStuff;
use UserPreference;

use base 'Form::Processor';

sub init_item {
    my $self = shift;
    my $id = $self->item_id;

    return unless defined $id;

    my $mb = new MusicBrainz;
    $mb->Login();

    my $us = new UserStuff($mb->{DBH});
    my $user = $us->newFromName($id);

    my $prefs = UserPreference->newFromUser ($user);
    $prefs->load;

    return $prefs;
}

sub init_value {
    my ($self, $field, $item) = @_;

    $item ||= $self->item;

    return $item->get($field->name);
}

sub update_model {
    my $self = shift;
    my $item = $self->item;

    my $mb = new MusicBrainz;
    $mb->Login();
    $self->item->{DBH} = $mb->{DBH};

    for my $field ($self->fields)
    {
        $self->item->set ($field->name, $field->value);
    }

    $self->item->save;
}

sub update_from_form {
    my ($self, $data) = @_;

    return unless $self->validate($data);
    $self->update_model;
}

1;
