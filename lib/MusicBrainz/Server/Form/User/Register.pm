package MusicBrainz::Server::Form::User::Register;

use strict;
use warnings;

use MusicBrainz;
use MusicBrainz::Server::Editor;

use base 'MusicBrainz::Server::Form';

=head1 NAME

MusicBrainz::Server::Form::User::Register;

=head1 DESCRIPTION

Provide a form for new users to register on the site

=head1 METHODS

=head2 name

Returns the name of this form

=cut

sub name { "register"; }

=head2

Returns a list of required and optional fields in this form

=cut

sub profile {
    return {
        required => {
            username => 'Text',
            password => {
                type => 'Text',
                min_length => 1,
                widget => 'Password'
            },
            confirm_password => {
                type => 'Text',
                min_length => 1,
                widget => 'Password'
            },
        },
        optional => {
            email => '+MusicBrainz::Server::Form::Field::Email'
        }
    };
}

=head2 cross_validate

Cross validate the 2 given passwords to make sure they match

=cut

sub cross_validate {
    my $self = shift;

    my ($pass, $confirm) = ( $self->field('password'),
                             $self->field('confirm_password') );

    $confirm->add_error("Both provided passwords must be equal")
        if $confirm->value ne $pass->value;
}

=head2 model_validate

Make sure that the username does not already exist

=cut

sub model_validate
{
    my $self = shift;

    my $mb = new MusicBrainz;
    $mb->Login;

    my $us = new MusicBrainz::Server::Editor($mb->{dbh});
    my $user = $us->newFromName($self->value('username'));

    $self->field('username')->add_error('This username is already taken')
        if $user;
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
