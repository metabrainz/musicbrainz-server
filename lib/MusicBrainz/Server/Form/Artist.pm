package MusicBrainz::Server::Form::Artist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use ModDefs;
use Moderation;
use MusicBrainz;
use MusicBrainz::Server::Artist;

=head1 NAME

MusicBrainz::Server::Form::Artist - form representation for creating
and editing artists.

=head1 DESCRIPTION

This handles the validation of form fields, along with inserting the
new data into the database appropriatly.

=head1 METHODS

=head2 name

Gets the name of this form.

=cut

sub name { 'edit_artist' }

=head2 profile

Returns a hash reference of fields that are in this form, organised by
required and optional fields.

=cut

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

=head2 options_artist_type

Options used for the "artist type" combo field.

=cut

sub options_artist_type {
    [ MusicBrainz::Server::Artist::ARTIST_TYPE_PERSON, "Person",
      MusicBrainz::Server::Artist::ARTIST_TYPE_GROUP, "Group",
      MusicBrainz::Server::Artist::ARTIST_TYPE_UNKNOWN, "Unknown" ]
}

=head2 init_item

If we have been passed an artist row ID at creation time, load this
artist so we can fill the form fields.

=cut

sub init_item {
    my $self = shift;
    my $id = $self->item_id;

    return unless defined $id;

    my $mb = new MusicBrainz;
    $mb->Login();

    my $artist = MusicBrainz::Server::Artist->newFromId($mb->{DBH}, $id);

    return $artist;
}

=head2 init_value

Initialize the value for a form field, given the name of the field.

=cut

sub init_value {
    my ($self, $field, $item) = @_;
    $item ||= $self->item;

    return unless defined $item;
    
    use Switch;
    switch($field->name)
    {
        return $item->GetName case ('name');
        return $item->sort_name case('sortname');
        return $item->type case('artist_type');
        return $item->begin_date case('start');
        return $item->end_date case('end');
        case('resolution') {
            my $resolution = $item->resolution;
            $field->required(1) if $resolution;
            return $resolution;
        };
    }
}

=head2 update_model

Updates the information in the MusicBrainz database.

If an artist was not originally provided, this creates a new artist. If
an artist was provided, it updates that given artist. All edits are
entered via the moderation system.

=cut 

sub update_model {
    my $self = shift;
    my $item = $self->item;

    my $user = $self->context->user->get_object;

    my %moderation;
    $moderation{DBH} = $self->context->mb->{DBH};
    $moderation{uid} = $user->GetId;
    $moderation{privs} = $user->GetPrivs;

    my ($begin, $end) =
        (
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('start') || '') ],
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('end') || '') ],
        );

    # Split these into 2 separate conditions because the keys are slightly different
    # and the default values are also slightly different.
    if(defined $item)
    {
        # An artist was passed when we created the form, so this is an update edit
        $moderation{type} = ModDefs::MOD_EDIT_ARTIST;

        $moderation{artist} = $item;
        $moderation{name} = $self->value('name') || $item->GetName;
        $moderation{sortname} = $self->value('sortname') || $item->sort_name;
        $moderation{artist_type} = $self->value('artist_type') || $item->type;
        $moderation{resolution} = $self->value('resolution') || $item->resolution;

        $moderation{begindate} = $begin;
        $moderation{enddate} = $end;
    }
    else
    {
        # No artist was passed, so we are creating a new artist.
        $moderation{type} = ModDefs::MOD_ADD_ARTIST;

        $moderation{name} = $self->value('name');
        $moderation{sortname} = $self->value('sortname');
        $moderation{mbid} = '';
        $moderation{artist_type} = $self->value('artist_type');
        $moderation{artist_resolution} = $self->value('resolution') || '';

        $moderation{artist_begindate} = $begin;
        $moderation{artist_enddate} = $end;
    }

    my @mods = Moderation->InsertModeration(%moderation);

    $mods[0]->InsertNote($user->GetId, $self->value('edit_note'))
        if $mods[0] and $self->value('edit_note') =~ /\S/;

    return \@mods;
}

=head2 update_from_form

A small helper method to validate the form and update the database if validation succeeds in one easy call.

=cut

sub update_from_form {
    my ($self, $data) = @_;

    return unless $self->validate($data);
    $self->update_model;
}

=head1 LICENSE 

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;

