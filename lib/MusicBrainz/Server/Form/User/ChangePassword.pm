package MusicBrainz::Server::Form::User::ChangePassword;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

=head1 NAME

MusicBrainz::Server::Form::User::ChangePassword - form to allow users
to change password.

=head1 DESCRIPTION

Handles the validation of the change password form. Does not actually
perform the password changing logic.

=cut


=head1 name

Returns the name of this form

=cut

sub name { 'user_changePass' }

=head1 profile

Returns a hash reference of the fields of this form.

=cut

sub profile {
    return {
        required => {
            old_password => {
                type => 'Text',
                min_length => 1,
                widget => 'Password'
            },
            new_password => {
                type => 'Text',
                min_length => 1,
                widget => 'Password'
            },
            confirm_new_password => 'Password',
        },
    };
}

=head1 cross_validate

Performs cross validation between the "confirm password" fields.

=cut

sub cross_validate {
    my ($self) = @_;

    my ($new, $confirm) = ( $self->field('new_password'),
                            $self->field('confirm_new_password') );

    $confirm->add_error("The new password fields must match")
        if $confirm->value ne $new->value;
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
