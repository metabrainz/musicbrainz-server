package MusicBrainz::Server::Form::User::Login;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

=head1 NAME 

MusicBrainz::Server::Form::User::Login;

=head1 DESCRIPTION

Allow users to login to the site

=head1 METHODS

=head2 name

Returns a name for this form

=cut

sub name { 'user-login' }

=head2 profile

Returns a list of optional and required form fields

=cut

sub profile
{
    return {
        required => {
            username => 'Text',
            password => {
                type => 'Text',
                min_length => 1,
                widget => 'password'
            },
        },
        optional => {
            single_ip => 'Checkbox',
            remember_me => 'Checkbox',
        }
    }
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
