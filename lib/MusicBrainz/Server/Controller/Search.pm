package MusicBrainz::Server::Controller::Search;

use strict;
use warnings;

use base 'Catalyst::Controller';

use UserStuff;

=head1 NAME

MusicBrainz::Server::Controller::Search - Handles searching the database

=head1 DESCRIPTION

This control handles searching the database for various data, such as
artists and releases, but also MusicBrainz specific data, such as editors
and tags.

=head1 METHODS

=cut

# simple {{{

=head2 simple

Handle a "simple" search which has a type and a query. This then redirects
to whichever specific search action the search type maps to.

=cut
sub simple : Local {
    my ($self, $c) = @_;

    use MusicBrainz::Server::Form::Search::Simple;

    my $form = new MusicBrainz::Server::Form::Search::Simple;

    if ($c->form_posted && $form->validate($c->req->params))
    {
        $c->session->{last_simple_search} = $form->value('type');
        $c->detach($form->value('type'), [ $form->value('query') ]);
    }

    $c->stash->{template} = 'search/simple.tt';
}
# }}}
# editor {{{

=head2 editor

Serach for a MusicBrainz database.

This search is performed right in this action, and is not dispatched to
one of the MusicBrainz search servers. It searches for a moderator with
the exact name given, and if found, redirects to their profile page. If
no moderator could be found, the user is informed.

=cut

sub editor : Local {
    my ($self, $c, $query) = @_;

    my $us = new UserStuff ($c->mb->{DBH});
    my $user = $us->newFromName($query);

    if(defined $user)
    {
        $c->response->redirect($c->uri_for('/user/profile', $user->GetName));
        $c->detach;
    }
    else
    {
        $c->stash->{could_not_find_user} = 1;
        $c->stash->{query} = $query;
        $c->stash->{template} = 'search/editor.tt';
    }
}
# }}}
# artist {{{
sub artist : Local {
    my ($self, $c) = @_;
    die "This search not yet written";
}
# }}}
# release {{{
sub release : Local {
    my ($self, $c) = @_;
    die "This search not yet written";
}
# }}}
# track {{{
sub track : Local {
    my ($self, $c) = @_;
    die "This search not yet written";
}
# }}}
# label {{{
sub label : Local {
    my ($self, $c) = @_;
    die "This search not yet written";
}
# }}}

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
