package MusicBrainz::Server::Form::Artist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use ModDefs;
use Moderation;
use MusicBrainz;
use MusicBrainz::Server::Artist;

sub name { 'edit_artist' }

sub profile
{
    return {
        required => {
            name => 'Text',
            sortname => 'Text',
            artist_type => 'Select'
        },
        optional => {
            start => '+MusicBrainz::Server::Form::Field::Date',
            end => '+MusicBrainz::Server::Form::Field::Date',
            edit_note => 'TextArea',

            # We make this required if duplicates are found,
            # or if a resolution is present when we edit the artist.
            resolution => 'Text'
        }
    };
}

sub options_artist_type {
    [ MusicBrainz::Server::Artist::ARTIST_TYPE_PERSON, "Person",
      MusicBrainz::Server::Artist::ARTIST_TYPE_GROUP, "Group",
      MusicBrainz::Server::Artist::ARTIST_TYPE_UNKNOWN, "Unknown" ]
}

sub validate_artist_type {
    my ($self, $field) = @_;

    $field->add_error($field->value . " is not a valid type")
        unless MusicBrainz::Server::Artist::IsValidType($field->value);
}

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
    $item ||= $self->item;
    
    use Switch;
    switch($field->name)
    {
        return $item->GetName case ('name');
        return $item->GetSortName case('sortname');
        return $item->GetType case('artist_type');
        return $item->GetBeginDate case('start');
        return $item->GetEndDate case('end');
        case('resolution') {
            my $resolution = $item->GetResolution;
            $field->required(1) if $resolution;
            return $resolution;
        };
    }
}

sub update_model {
    my $self = shift;
    my $item = $self->item;

    my $mb = new MusicBrainz;
    $mb->Login();

    my $user = $self->context->user->get_object;

    use Data::Dumper;
    my @startDate = 

    my @mods = Moderation->InsertModeration(
        DBH => $mb->{DBH},
        uid => $user->GetId,
        privs => $user->GetPrivs,
        type => ModDefs::MOD_EDIT_ARTIST,

        artist => $item,
        name => $self->value('name') || $item->GetName,
        sortname => $self->value('sortname') || $item->GetSortName,
        artist_type => $self->value('artist_type') || $item->GetType,
        resolution => $self->value('resolution') || $item->GetResolution,
        begindate => [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('start')) ],
        enddate => [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('end')) ],
    );

    $mods[0]->InsertNote($user->GetId, $self->value('edit_note'))
        if $mods[0] and $self->value('edit_note') =~ /\S/;

    1;
}

sub update_from_form {
    my ($self, $data) = @_;

    return unless $self->validate($data);
    $self->update_model;
}

1;

