package MusicBrainz::Server::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

# Import MusicBrainz libraries
use DBDefs;
use MusicBrainz::Server::NewsFeed;
use MusicBrainz::Server::Replication ':replication_type';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

MusicBrainz::Server::Controller::Root - Root Controller for musicbrainz

=head1 DESCRIPTION

This controller handles application wide logic for the MusicBrainz website.

=head1 METHODS

=cut

# auto {{{
=head2 auto

Runs before any other action is dispatched, so we use this to make sure the user can view the page
(and redirect them if they need to login)

=cut

sub auto : Private {
    my ($self, $c) = @_;

    my %private;
    for (@{$c->config->{privatePages}}) { $private{$_} = 1; }

    if (!$c->user_exists && $private{$c->action})
    {
        $c->flash->{login_redirect} = $c->uri_for($c->action, $c->req->args);
        $c->response->redirect($c->uri_for('/user/login'));
        return 0;
    }

    return 1;
}
# }}}

=head2 index

Render the standard MusicBrainz welcome page, which is mainly static, other than the blog feed.

=cut

sub index : Path Args(0)
{
    my ($self, $c) = @_;

    $c->stash->{server_details} = {
        is_slave_db => &DBDefs::REPLICATION_TYPE == RT_SLAVE,
        staging_server => &DBDefs::DB_STAGING_SERVER,
    };

    # Load the blog for the sidebar
    # 
    my $feed = MusicBrainz::Server::NewsFeed->new(
        url => 'http://blog.musicbrainz.org/?feed=rss2',
        update_interval => 5 * 60,
        max_items => 3);
    
    if (defined $feed)
    {
        $feed->Load();

        # Process the items to a template friendly data structure
        $c->stash->{blog} = [];

        foreach my $item ($feed->GetItems())
        {
            push @{ $c->stash->{blog} }, {
                title => $item->GetTitle,
                description => $item->GetDescription,
                date_time => $item->GetDateTimeString,
                link => $item->GetLink,
            };
        }
    }

    $c->stash->{template} = 'main/index.tt';
}

=head2 default

Handle any pages not matched by a specific controller path. In our case, this means serving a
404 error page.

=cut

sub default : Path
{
    my ($self, $c) = @_;
    
    $c->response->body('Page not found');
    $c->response->status(404);    
}

=head2 end

Attempt to render a view, if needed. This will also set up some global variables in the 
context containing important information about the server used on the majority of templates,
and also the current user.

=cut 

sub end : ActionClass('RenderView')
{
    my ($self, $c) = @_;

    # Setup the searchs on the sidebar
    use MusicBrainz::Server::Form::Search::Simple;
    my $simpleSearch = new MusicBrainz::Server::Form::Search::Simple;
    $simpleSearch->field('type')->value($c->session->{last_simple_search} || 'artist');
    $c->stash->{sidebar_search} = $simpleSearch;

    $c->stash->{server_details}->{version} = &DBDefs::VERSION;
}

=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
1;
