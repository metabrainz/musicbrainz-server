package MusicBrainz::Server::Controller::Tags;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use Data::Page;
use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Label;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Tag;
use MusicBrainz::Server::Track;

=head1 NAME

MusicBrainz::Server::Controller::Tag

=head1 DESCRIPTION

Handles user interaction with folksonomy tags

=head1 METHODS

=head2 display

Display all entities that relate to a given tag.

=cut

sub display_summary : Path Args(1)
{
    my ($self, $c, $tag) = @_;

    $c->stash->{tag_types} = [ map {
        my ($tags, $count) = $c->model('Tag')->tagged_entities(
            $tag, $_, 10, 0
        );
        
        {
            type     => $_,
            entities => $tags,
        }
    } qw/artist label release track/ ];

    $c->stash->{tag} = $tag;
    $c->stash->{template} = 'tag/display_summary.tt';
}

sub display : Path Args(2)
{
    my ($self, $c, $tag, $type) = @_;
    
    die "$type is not a valid type of entity"
        unless grep { $type eq $_ } qw/ artist label track release /;
    
    my $page = $c->req->params->{page} || 1;
    
    my $pager = Data::Page->new;
    $pager->current_page($page);
    $pager->entries_per_page(50);
    
    my ($tags, $count) = $c->model('Tag')->tagged_entities(
        $tag, $type, $pager->entries_per_page, ($page - 1) * $pager->entries_per_page
    );
    
    $pager->total_entries($count);
    
    $c->stash->{tag}      = $tag;
    $c->stash->{type}     = $type;
    $c->stash->{entities} = $tags;
    $c->stash->{pager}    = $pager;
    $c->stash->{template} = 'tag/display.tt';
}

=head2 entity

Used for tag information applied to a specific MusicBrainz entity.

=cut

sub entity : Form('Tag::Tags')
{
    my ($self, $c, $entity) = @_;

    my $form = $self->form;

    if ($c->user_exists)
    {
	my $rawtags = $c->model('Tag')->raw_tags($entity, $c->user);
	$form->field('tags')->value(join ",", map { $_->{name} } @$rawtags);

	if ($self->submit_and_validate($c))
        {
	    $c->model('Tag')->update_user_tags($entity, $c->user, $form->value('tags') || '');
	}
    }

    $c->stash->{tagcloud} = $c->model('Tag')->generate_tag_cloud($entity);
    $c->stash->{template} = 'tag/tags.tt';
}

=head2 all

Show all the tags in the database in a tag cloud

=cut

sub all : Local
{
    my ($self, $c) = @_;

    $c->stash->{tagcloud} = $c->model('Tag')->generate_tag_cloud();
    $c->stash->{template} = 'tag/all.tt';
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
