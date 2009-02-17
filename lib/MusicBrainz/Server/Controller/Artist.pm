package MusicBrainz::Server::Controller::Artist;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

__PACKAGE__->config(
    model       => 'Artist',
    entity_name => 'artist',
);

use Data::Page;
use MusicBrainz::Server::Adapter qw(Google);
use MusicBrainz::Server::Rating;
use ModDefs;
use UserSubscription;

=head1 NAME

MusicBrainz::Server::Controller::Artist - Catalyst Controller for working
with Artist entities

=head1 DESCRIPTION

The artist controller is used for interacting with
L<MusicBrainz::Server::Artist> entities - both read and write. It provides
views to the artist data itself, and a means to navigate to a release
that is attributed to a certain artist.

=head1 ACTIONS

=head2 READ ONLY PAGES

The follow pages can are all read only.

=head2 base

Base action to specify that all actions live in the C<artist>
namespace

=cut

sub base : Chained('/') PathPart('artist') CaptureArgs(0) { }

=head2 artist

Extends loading by disallowing the access of the special artist
C<DELETED_ARTIST>, and fetching any extra data required in
the artist header.

=cut

sub artist : Chained('load') PathPart('') CaptureArgs(0)
{
    my ($self, $c) = @_;

    if ($self->entity->id == ModDefs::DARTIST_ID)
    {
        $c->detach('/error_404');
    }

	if ($c->user_exists)
	{
    	$c->stash->{subscribed} = $c->model('Subscription')->
        	is_user_subscribed_to_entity($c->user, $self->entity);
	}
}

=head2 similar

Display artists similar to this artist

=cut

sub similar : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;

    $c->stash->{similar_artists} = $c->model('Artist')->find_similar_artists($artist);
}

=head2 google

Search Google for this artist

=cut

sub google : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;

    $c->response->redirect(Google($artist->name));
}

=head2 tags

Show all of this artists tags

=cut

sub tags : Chained('artist')
{
    my ($self, $c) = @_;
    $c->forward('/tags/entity', [ $self->entity ]);
}

=head2 relations

Shows all the entities (except track) that this artist is related to.

=cut

sub relations : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;

    $c->stash->{relations} = $c->model('Relation')->load_relations($artist, to_type => [ 'artist', 'url', 'label', 'album' ]);
}

=head2 appearances

Display a list of releases that an artist appears on via advanced
relations.

=cut

sub appearances : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;

    $c->stash->{releases} = $c->model('Release')->find_linked_albums($artist);
}

=head2 perma

Display the perma-link for a given artist.

=cut

# Empty because everything we need is in added to the stash with sub artist.
sub perma : Chained('artist') { }

=head2 details

Display detailed information about a specific artist.

=cut

# Empty because everything we need is in added to the stash with sub artist.
sub details : Chained('artist') { }

=head2 aliases

Display all aliases of an artist, along with usage information.

=cut

sub aliases : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;

    $c->stash->{aliases}  = $c->model('Alias')->load_for_entity($artist);
}

=head2 nats

Show all this artists non-album tracks

=cut

sub nats : Chained('artist')
{
    my ($self, $c) = @_;

    $c->stash->{release} = $c->model('Release')->nat_release($self->entity);

    if ($c->stash->{release})
    {
        $c->stash->{release_artist} = $self->entity;
        $c->forward('/release/show');
    }
    else
    {
        $c->stash->{template} = 'artist/no_nats.tt';
    }
}

=head2 show

Shows an artist's main landing page.

This page shows the main releases (by default) of an artist, along with a
summary of advanced relations this artist is involved in. It also shows
folksonomy information (tags).

=cut

sub show : PathPart('') Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;
    
    if ($artist->id == ModDefs::VARTIST_ID)
    {
        $c->detach('_show_various');
    }
    else
    {
        my $show_all = $c->req->query_params->{show_all} || 0;

        $c->stash->{tags}       = $c->model('Tag')->top_tags($artist);
        $c->stash->{releases}   = $c->model('Release')->load_for_artist($artist, $show_all);
        $c->stash->{relations}  = $c->model('Relation')->load_relations($artist, to_type => [ 'artist', 'url', 'label', 'album' ]);
        $c->stash->{annotation} = $c->model('Annotation')->load_revision($artist);

        my $id = $c->user_exists ? $c->user->id : 0;
        $c->stash->{show_ratings} = $id ? $c->user->preferences->get("show_ratings") : 1;

        if ($c->stash->{show_ratings})
        {
            $c->stash->{artist_rating} = $c->model('Rating')->get_rating({
                entity_type     => 'artist',
                entity_id       => $c->stash->{artist}->id,
                user_id         => $id,
            });
            MusicBrainz::Server::Rating::LoadUserRatingForEntities("release", $c->stash->{releases}, $id);
        }

        # Decide how to display the data
        $c->stash->{template} = defined $c->request->query_params->{full} ? 
                                    'artist/full.tt' :
                                    'artist/compact.tt';
    }
}

=head2 _show_various

This internal action handles displaying the various artist browse page,
as there are simply far too many releases to display on one page

=cut

sub _show_various : Private
{
    my ($self, $c) = @_;
    
    my $page = $c->req->query_params->{page} || 1;
    
    my $pager = Data::Page->new;
    $pager->entries_per_page(50);
    $pager->current_page($page);
    
    my $index = uc $c->req->query_params->{index} || '';
    
    my ($count, $releases) = $c->model('Release')->
        get_browse_selection($index, ($page - 1) * $pager->entries_per_page );

    $pager->total_entries($count);

    $c->stash->{count}    = $count;
    $c->stash->{releases} = $releases;
    $c->stash->{pager}    = $pager;
    
    $c->stash->{template} = 'artist/browse_various.tt';
}

=head2 WRITE METHODS

These methods write to the database (create/update/delete)

=head2 create

When given a GET request this displays a form allowing the user to enter
data, creating a new artist. If a POST request is received, the data
is validated and if validation succeeds, the artist is entered into the
MusicBrainz database.

The heavy work validating the form and entering data into the database
is done via L<MusicBrainz::Server::Form::Artist>

=cut

sub create : Local Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $form = $self->form;

    if ($c->form_posted) {
        $form->validate($c->req->params);
        
        my $dupes = $c->model('Artist')->search_by_name($form->value('name'));
        $c->stash->{dupes} = $dupes;
    }

    return unless $self->submit_and_validate($c);

    my $created_artist = $form->create;

    if ($created_artist)
    {
        $c->flash->{ok} = "Thanks! The artist has been added to the " .
                          "database, and we have redirected you to " .
                          "their landing page";

        $c->response->redirect($c->entity_url($created_artist, 'show'));
    }
}

=head2 edit

Allows users to edit the data about this artist.

When viewed with a GET request, the user is displayed a form filled with
the current artist data. When a POST request is received, the data is
validated and if it passed validation is the updated data is entered
into the MusicBrainz database.

=cut

sub edit : Chained('artist') Form
{
    my ($self, $c, $mbid) = @_;

    $c->forward('/user/login');

    my $form = $self->form;
    $form->init($self->entity);

    if ($c->form_posted) {
        $form->validate($c->req->params);
        
        my $dupes = $c->model('Artist')->search_by_name($form->value('name'));
        $c->stash->{dupes} = [ grep { $_->id != $self->entity->id } @$dupes ];
    }

    return unless $self->submit_and_validate($c);

    $form->apply_edit;

    $c->flash->{ok} = "Thanks, your artist edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($self->entity, 'show'));
}

=head2 merge

Merge 2 artists into a single artist

=cut

sub merge : Chained('artist')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');
    $c->forward('/search/filter_artist');

    my $target = $c->stash->{search_result};
    if (defined $target)
    {
        my $artist = $self->entity;
        $c->response->redirect($c->entity_url($artist, 'merge_into',
					      $target->id));
    }
    else
    {
        $c->stash->{template} = 'artist/merge_search.tt';
    }
}

sub merge_into : Chained('artist') PathPart('merge-into') Args(1)
                 Form('Artist::Merge')
{
    my ($self, $c, $new_mbid) = @_;

    $c->forward('/user/login');

    my $form       = $self->form;
    my $artist     = $self->entity;
    my $new_artist = $c->model('Artist')->load($new_mbid);

    $c->stash->{new_artist} = $new_artist;
    $c->stash->{template  } = 'artist/merge.tt';

    $form->init($artist);

    return unless $self->submit_and_validate($c);

    $form->merge_into($new_artist);

    $c->flash->{ok} = "Thanks, your artist edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($new_artist, 'show'));
}

=head2 rating

Rate an artist

=cut

sub rating : Chained('artist') Args(2)
{
    my ($self, $c, $entity, $new_vote) = @_;
    #Need more validation here

    $c->forward('/user/login');
    $c->forward('/rating/do_rating', ['artist', $entity, $new_vote] );
    $c->response->redirect($c->entity_url($self->entity, 'show'));
}

=head2 subscribe

Allow a moderator to subscribe to this artist

=cut

sub subscribe : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    $c->forward('/user/login');

    my $us = UserSubscription->new($c->mb->{dbh});
    $us->SetUser($c->user->id);
    $us->SubscribeArtists($artist);
    $c->stash->{subscribed} = 1;

    $c->forward('subscriptions');
}

=head2 unsubscribe

Unsubscribe from an artist

=cut

sub unsubscribe : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    $c->forward('/user/login');

    my $us = UserSubscription->new($c->mb->{dbh});
    $us->SetUser($c->user->id);
    $us->UnsubscribeArtists($artist);
    $c->stash->{subscribed} = undef;

    $c->forward('subscriptions');
}

=head2 subscriptions

Show all users who are subscribed to this artist, and have stated they
wish their subscriptions to be public

=cut

sub subscriptions : Chained('artist')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $artist = $c->stash->{artist};

    my @all_users = $artist->subscribers;

    my @public_users;
    my $anonymous_subscribers;

    for my $uid (@all_users)
    {
        my $user = $c->model('User')->load({ id => $uid });

        my $public = UserPreference::get_for_user("subscriptions_public", $user);
        my $is_me  = $c->user_exists && $c->user->id == $user->id;

        if ($is_me) { $c->stash->{user_subscribed} = $is_me; }

        if ($public || $is_me)
        {
            push @public_users, $user;
        }
        else
        {
            $anonymous_subscribers++;
        }
    }

    $c->stash->{subscribers          } = \@public_users;
    $c->stash->{anonymous_subscribers} = $anonymous_subscribers;

    $c->stash->{template} = 'artist/subscribe.tt';
}

=head2 import

Import a release from another source (such as FreeDB)

=cut

sub import : Local
{
    my ($self, $c) = @_;
    die "This is a stub method";
}

=head2 add_non_album

Add non-album tracks to this artist (creating the special non-album
release if necessary)

=cut

sub add_non_album : Chained('artist') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $artist = $self->entity;

    my $form = $self->form;
    $form->init($artist);

    return unless $self->submit_and_validate($c);

    $form->add_track;

    $c->flash->{ok} = 'Thanks, your edit has been entered into the moderation queue';

    $c->response->redirect($c->entity_url($artist, 'show'));
}

=head2 change_quality

Change the data quality of this artist

=cut

sub change_quality : Chained('artist') Form('DataQuality')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $artist = $self->entity;

    my $form = $self->form;
    $form->init($artist);

    return unless $self->submit_and_validate($c);

    $form->change_quality($c->model('Artist'));

    $c->flash->{ok} = "Thanks, your artist edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($artist, 'show'));
}

=head2 add_alias

Allow users to add an alias to this artist

=cut

sub add_alias : Chained('artist') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $form = $self->form;

    return unless $self->submit_and_validate($c);

    $form->create_for($self->entity);

    $c->flash->{ok} = "Thanks, your artist edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($self->entity, 'aliases'));
}

=head2 remove_alias

Allow users to remove an alias from an artist

=cut

sub remove_alias : Chained('artist') Args(1) Form
{
    my ($self, $c, $alias_id) = @_;

    my $artist = $self->entity;
    my $alias  = $c->model('Alias')->load($artist, $alias_id);

    $c->stash->{alias} = $alias;

    my $form = $self->form;
    $form->init($alias);

    return unless $self->submit_and_validate($c);

    $form->remove_from($artist);

    $c->flash->{ok} = "Thanks, your artist edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($artist, 'aliases'));
}

=head2 edit_alias

Alow users to edit an alias for an artist

=cut

sub edit_alias : Chained('artist') Args(1) Form
{
    my ($self, $c, $alias_id) = @_;

    my $artist = $c->stash->{artist};
    my $alias  = $c->model('Alias')->load($artist, $alias_id);

    my $form = $self->form;
    $form->init($alias);

    $c->stash->{alias   } = $alias;
    $c->stash->{template} = 'artist/edit_alias.tt';

    return unless $self->submit_and_validate($c);

    $form->edit_for($artist);

    $c->flash->{ok} = "Thanks, your artist edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($artist, 'aliases'));
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
