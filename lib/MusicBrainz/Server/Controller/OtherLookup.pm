package MusicBrainz::Server::Controller::OtherLookup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use Moose::Util qw( find_meta );
use MusicBrainz::Server::Translation qw ( l );
use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );

sub lookup_handler {
    my ($name, $code) = @_;

    my $method = sub {
        my ($self, $c) = @_;
        my $form = $c->form(other_lookup => 'OtherLookup');
        $form->field($name)->required(1);

        if ($form->submitted_and_valid($c->req->query_params)) {
            $self->$code($c, $form->field($name)->value);
        }
        else {
            $c->stash( template => 'otherlookup/index.tt' );
        }
    };

    # Add the method
    find_meta(__PACKAGE__)->add_method(
        $name => $method
    );

    # Add the ':Local' attribute
    find_meta(__PACKAGE__)->register_method_attributes($method, [qw( Local )]);
}

lookup_handler 'catno' => sub {
    my ($self, $c, $cat_no) = @_;

    $c->response->redirect(
        $c->uri_for_action ('/search/search', {
            query => 'catno:' . $cat_no,
            type => 'release',
            advanced => '1',
        }));

    $c->detach;
};

lookup_handler 'barcode' => sub {
    my ($self, $c, $barcode) = @_;

    $c->response->redirect(
        $c->uri_for_action ('/search/search', {
            query => 'barcode:' . $barcode,
            type => 'release',
            advanced => '1',
        }));

    $c->detach;
};

lookup_handler 'mbid' => sub {
    my ($self, $c, $gid) = @_;

    for my $model (qw(Artist Label Recording Release ReleaseGroup Track URL Work)) {
        my $entity = $c->model($model)->get_by_gid($gid) or next;
        $c->response->redirect(
            $c->uri_for_action(
                $c->controller($model)->action_for('show'),
                [ $gid ]));
        $c->detach;
    }

    $self->not_found($c);
};

lookup_handler 'isrc' => sub {
    my ($self, $c, $isrc) = @_;

    $c->response->redirect($c->uri_for_action('/isrc/show', [ $isrc ]));
    $c->detach;
};

lookup_handler 'iswc' => sub {
    my ($self, $c, $iswc) = @_;

    my @works = $c->model('Work')->find_by_iswc($iswc);
    if (@works == 1) {
        my $work = $works[0];
        $c->response->redirect(
            $c->uri_for_action(
                $c->controller('Work')->action_for('show'),
                [ $work->gid ]));
        $c->detach;
    }
    elsif (@works > 1) {
        $c->model('Work')->load_writers(@works);
        $c->model('Work')->load_recording_artists(@works);
        $c->stash(
            works => \@works,
            template => 'otherlookup/results-work.tt'
        );
    }
    else {
        $c->detach('not_found');
    }
};

lookup_handler 'artist-ipi' => sub {
    my ($self, $c, $ipi) = @_;

    $c->response->redirect(
        $c->uri_for_action ('/search/search', {
            query => 'ipi:' . $ipi,
            type => 'artist',
            advanced => '1',
        }));

    $c->detach;
};

lookup_handler 'artist-isni' => sub {
    my ($self, $c, $isni) = @_;

    $c->response->redirect(
        $c->uri_for_action ('/search/search', {
            query => 'isni:' . $isni,
            type => 'artist',
            advanced => '1',
        }));

    $c->detach;
};

lookup_handler 'label-ipi' => sub {
    my ($self, $c, $ipi) = @_;

    $c->response->redirect(
        $c->uri_for_action ('/search/search', {
            query => 'ipi:' . $ipi,
            type => 'label',
            advanced => '1',
        }));

    $c->detach;
};

lookup_handler 'label-isni' => sub {
    my ($self, $c, $isni) = @_;

    $c->response->redirect(
        $c->uri_for_action ('/search/search', {
            query => 'isni:' . $isni,
            type => 'label',
            advanced => '1',
        }));

    $c->detach;
};

lookup_handler 'puid' => sub {
    my ($self, $c, $puid) = @_;

    $c->response->redirect($c->uri_for_action('/puid/show', [ $puid ]));
    $c->detach;
};

lookup_handler 'discid' => sub {
    my ($self, $c, $discid) = @_;

    $c->response->redirect($c->uri_for_action('/cdtoc/show', [ $discid ]));
    $c->detach;
};

lookup_handler 'freedbid' => sub {
    my ($self, $c, $freedbid) = @_;

    my @cdtocs = $c->model ('CDTOC')->find_by_freedbid (lc($freedbid));

    my @medium_cdtocs = map {
        $c->model('MediumCDTOC')->find_by_discid($_->discid);
    } @cdtocs;

    my @mediums = $c->model('Medium')->load(@medium_cdtocs);
    my @releases = $c->model('Release')->load(@mediums);

    $c->model('ArtistCredit')->load (@releases);
    load_release_events($c, @releases);
    $c->model('Language')->load(@releases);
    $c->model('Script')->load(@releases);
    $c->model('Medium')->load_for_releases(@releases);

    $c->stash(
        releases => \@releases,
        template => 'otherlookup/results-release.tt'
    )
};

sub index : Path('')
{
    my ($self, $c) = @_;
    my $form = $c->form( other_lookup => 'OtherLookup' );
}

1;

=head1 LICENSE

Copyright (C) 2010 MetaBrainz Foundation

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
