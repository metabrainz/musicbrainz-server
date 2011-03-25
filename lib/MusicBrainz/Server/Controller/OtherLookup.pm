package MusicBrainz::Server::Controller::OtherLookup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Form::OtherLookup;
use MusicBrainz::Server::Translation qw ( l ln );
use MusicBrainz::Server::Validation qw( is_valid_isrc is_valid_iswc is_valid_discid );
use MusicBrainz::Server::Data::Search qw( escape_query );

sub _redirect
{
    my ($self, $c, $entity) = @_;
    my $uri;

    if ($entity->meta->name eq 'MusicBrainz::Server::Entity::Artist')
    {
        $uri = $c->uri_for_action('/artist/show', [ $entity->gid ])
    }
    elsif ($entity->meta->name eq 'MusicBrainz::Server::Entity::Label')
    {
        $uri = $c->uri_for_action('/label/show', [ $entity->gid ])
    }
    elsif ($entity->meta->name eq 'MusicBrainz::Server::Entity::Recording')
    {
        $uri = $c->uri_for_action('/recording/show', [ $entity->gid ])
    }
    elsif ($entity->meta->name eq 'MusicBrainz::Server::Entity::Release')
    {
        $uri = $c->uri_for_action('/release/show', [ $entity->gid ])
    }
    elsif ($entity->meta->name eq 'MusicBrainz::Server::Entity::ReleaseGroup')
    {
        $uri = $c->uri_for_action('/release_group/show', [ $entity->gid ])
    }
    elsif ($entity->meta->name eq 'MusicBrainz::Server::Entity::URL')
    {
        $uri = $c->uri_for_action('/url/show', [ $entity->gid ])
    }
    elsif ($entity->meta->name eq 'MusicBrainz::Server::Entity::Work')
    {
        $uri = $c->uri_for_action('/work/show', [ $entity->gid ])
    }

    $c->response->redirect( $uri );
    $c->detach;
}

# no results
sub not_found : Private
{
}

sub catno : Private
{
    my ($self, $c) = @_;

    my $uri = $c->uri_for_action ('/search/search', {
        query => 'catno:'.$c->req->query_params->{catno},
        type => 'release',
        advanced => '1',
    });

    $c->response->redirect( $uri );
    $c->detach;
}

sub barcode : Private
{
    my ($self, $c) = @_;

    my $uri = $c->uri_for_action ('/search/search', {
        query => 'barcode:'.$c->req->query_params->{barcode},
        type => 'release',
        advanced => '1',
    });

    $c->response->redirect( $uri );
    $c->detach;
}

sub mbid : Private
{
    my ($self, $c) = @_;

    my $gid =  $c->req->query_params->{mbid};

    if (!MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->stash->{error} = l('Invalid MBID');
        return;
    }

    my $entity;
    my @entities = qw(Artist Label Recording Release ReleaseGroup URL Work);
    for (@entities)
    {
        $entity = $c->model($_)->get_by_gid($gid);
        $self->_redirect ($c, $entity) if $entity;
    }

    $c->detach('not_found');
}

sub isrc : Private
{
    my ($self, $c) = @_;

    my $isrc =  $c->req->query_params->{isrc};

    if (!is_valid_isrc($isrc))
    {
        $c->stash->{error} = l('Invalid ISRC.');
        return;
    }

    my $uri = $c->uri_for_action('/isrc/show', [ $isrc ]);
    $c->response->redirect( $uri );
    $c->detach;
}

sub iswc : Private
{
    my ($self, $c) = @_;

    my $iswc =  $c->req->query_params->{iswc};

    if (!is_valid_iswc($iswc))
    {
        $c->stash->{error} = l('Invalid ISWC.');
        return;
    }

    my @works = $c->model('Work')->find_by_iswc($iswc);
    $c->detach('not_found') unless @works;

    if (@works == 1) {
        my $work = $works[0];
        $c->response->redirect(
            $c->uri_for_action('/work/show', [ $work->gid ])
        );
    }

    $c->model('ArtistCredit')->load (@works);
    $c->stash->{results} = \@works;
}

sub puid : Private
{
    my ($self, $c) = @_;

    my $puid =  $c->req->query_params->{puid};

    if (!MusicBrainz::Server::Validation::IsGUID($puid))
    {
        $c->stash->{error} = l('Invalid PUID.');
        return;
    }

    my $uri = $c->uri_for_action('/puid/show', [ $puid ]);
    $c->response->redirect( $uri );
    $c->detach;
}

sub discid : Private
{
    my ($self, $c) = @_;

    my $discid =  $c->req->query_params->{discid};

    if (!is_valid_discid($discid))
    {
        $c->stash->{error} = l('Invalid disc ID.');
        return;
    }

    my $uri = $c->uri_for_action('/cdtoc/show', [ $discid ]);
    $c->response->redirect( $uri );
    $c->detach;
}

sub freedbid : Private
{
    my ($self, $c) = @_;

    my $freedbid =  $c->req->query_params->{freedbid};

    my @cdtocs = $c->model ('CDTOC')->find_by_freedbid ($freedbid);

    my @medium_cdtocs;
    for (@cdtocs)
    {
        push @medium_cdtocs, $c->model('MediumCDTOC')->find_by_discid($_->discid);
    }

    my @mediums = $c->model('Medium')->load(@medium_cdtocs);
    my @releases = $c->model('Release')->load(@mediums);

    $c->model('ArtistCredit')->load (@releases);
    $c->stash->{results} = \@releases;
}

sub index : Path('')
{
    my ($self, $c) = @_;

    my $form = $c->form( query_form => 'OtherLookup' );
    $c->stash->{otherlookup} = $form;

    return unless $form->submitted_and_valid( $c->req->query_params );

    $c->stash->{template} = 'otherlookup/results.tt';

    $c->detach ('catno') if $c->req->query_params->{catno};
    $c->detach ('barcode') if $c->req->query_params->{barcode};
    $c->detach ('mbid') if $c->req->query_params->{mbid};
    $c->detach ('isrc') if $c->req->query_params->{isrc};
    $c->detach ('iswc') if $c->req->query_params->{iswc};
    $c->detach ('puid') if $c->req->query_params->{puid};
    $c->detach ('discid') if $c->req->query_params->{discid};
    $c->detach ('freedbid') if $c->req->query_params->{freedbid};
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
