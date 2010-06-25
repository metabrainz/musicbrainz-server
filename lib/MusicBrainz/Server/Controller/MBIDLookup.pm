package MusicBrainz::Server::Controller::MBIDLookup;

use strict;
use warnings;
use base 'MusicBrainz::Server::Controller';
use MusicBrainz::Server::Form::MBIDLookup;
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
        $uri = $c->uri_for_action('/release-group/show', [ $entity->gid ])
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

sub index : Path('')
{
    my ($self, $c) = @_;

    my $form = $c->form( query_form => 'MBIDLookup' );
    $c->stash->{mbidlookup} = $form;

    return unless $form->submitted_and_valid( $c->req->query_params );

    $c->stash->{template} = 'mbidlookup/results.tt';

    my $gid = $c->req->params->{mbid};

    if (!MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->stash->{error} = "Invalid mbid.";
        return;
    }

    my $entity;
    my @entities = qw(Artist Label Recording Release ReleaseGroup URL Work);
    for (@entities)
    {
        $entity = $c->model($_)->get_by_gid($gid);
        $self->_redirect ($c, $entity) if $entity;
    }

    $c->stash->{entity} = $entity->meta;
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
