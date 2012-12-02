package MusicBrainz::Server::Form::User::Login;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
extends 'HTML::FormHandler';

has_field 'username' => (
    type => 'Text',
    required => 1,
    messages => { required => l('Username field is required') }
);

has_field 'password' => (
    type => 'Password',
    required => 1,
    min_length => 1,
    messages => { required => l('Password field is required') }
);

has_field 'remember_me' => (
    type => 'Boolean'
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

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
