package MusicBrainz::Server::Form::User::ForgotPassword;

use strict;
use warnings;

use MusicBrainz::Server::Editor;

use base 'MusicBrainz::Server::Form';

=head1 NAME

MusicBrainz::Server::Form::User::ForgotPassword;

=head1 DESCRIPTION

Form to allow the user to have their password sent to them.

=head1 METHODS

=head2 name

Returns a name for this form

=cut

sub name { 'forgot-password' }

=head2 profile

Returns a list of fields for this form.

=cut

sub profile {
    return {
        optional => {
            username => 'Text',
            email => '+MusicBrainz::Server::Form::Field::Email',
        }
    };
}

=head2 model_validate

Make sure the given data for a field is valid; that is - the username
exists, and the email address also maps to a user (and if both are given
that they are the same).

=cut

sub model_validate
{
    my ($self) = @_;

    my $user;
    if ($self->value('username'))
    {
        my $us = new MusicBrainz::Server::Editor($self->context->mb->{dbh});
        $user = $us->newFromName($self->value('username'));

        $self->field('username')->add_error('This username does not exist')
            unless $user;
    }
}

=head2 cross_validate

We use this to ensure that at least one of the fields is filled in.

=cut

sub cross_validate 
{
    my $self = shift;

    $self->field('username')->add_error('You must enter either a username or email address')
        unless $self->value('username') or $self->value('email');
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
