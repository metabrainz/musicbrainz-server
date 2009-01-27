package MusicBrainz::Server::Form::User::EditProfile;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

=head1 NAME

MusicBrainz::Server::Form::User::EditProfile - a form for editing your
profile.

=head1 DESCRIPTION

Provides a form for updating a users own profile page. Also handles
database interactions.

=head1 METHODS

=head2 name

Gets the name for this form

=cut

sub name { 'edit-profile' }

=head2 profile

Returns a hash of required and optional form fields

=cut

sub profile {
    return {
        optional => {
            email => '+MusicBrainz::Server::Form::Field::Email',
            homepage => 'URL',
            biography => 'TextArea'
        }
    };
}

=head2 init_value

Initialize the value of the form fields from the users current information

=cut

sub init_value
{
    my ($self, $field, $item) = @_;
    my $item ||= $self->item;

    use Switch;
    switch ($field->name)
    {
	case ('email')     { return $item->email; }
	case ('homepage')  { return $item->web_url; }
	case ('biography') { return $item->biography; }
    }
}

=head2 update_model

Update the users profile in the database from the current values in
this form.

=cut

sub update_model
{
    my $self = shift;

    my %opts = (
        email => $self->value('email'),
        bio => $self->value('biography'),
        weburl => $self->value('homepage')
    );

    $self->item->SetUserInfo(%opts)
        or carp ("Could not update user profile");

    return 1;
}

=head2 update_from_form

Helper method to validate and update_model if appropriate.

=cut

sub update_from_form {
    my ($self, $data) = @_;

    $self->update_model
        unless $self->validate ($data);
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
