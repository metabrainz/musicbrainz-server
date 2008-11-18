#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2005 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

package MusicBrainz::Server::NewsFeed;

use strict;
use Carp;

use MusicBrainz::Server::Cache;
use LWP::UserAgent;

# Preload required modules
{
	my $ua = LWP::UserAgent->new(timeout => 1);
	scalar $ua->get("http://0.0.0.0/dummy");
}

# News feeds are cached to avoid downloading them too often.
# The value is in seconds.
#
use constant DEFAULT_UPDATE_INTERVAL => 10*60;


# Default constructor. Supported arguments:
#
# 	url				=>	Feed URL
#	update_interval	=>	time to keep the feed in the cache (in seconds)
#						if 0, don't use the cache
# 	max_items		=>	maximum number of items that GetItems() returns
# 	categories		=>	categories white list. example: ['Server', 'Client']
#
sub new
{
	my $proto = shift;
	my %args = @_;
	my $class = ref($proto) || $proto;

    eval {
        require XML::RSS;
    };
    return undef if (my $err = $@);

	croak "No url parameter given" unless $args{url};

	my $self = {
		url				=> $args{url},
		max_items		=> $args{max_items},
		categories		=> $args{categories} || [ ],
		update_interval	=> ( defined $args{update_interval} 
							? $args{update_interval} 
							: DEFAULT_UPDATE_INTERVAL ),
	};

	return bless($self, $class);
}


sub Load
{
	my $self = shift;
	my $url = $self->{url};

	croak "No parameter allowed" if @_;

	# Try to load the feed from the cache.
	#
	return 1 if $self->_LoadFromCache();

    require XML::RSS;
	my $rss = XML::RSS->new();

	# Load the feed from the url. Return undef on error.
	#
	if ( $url =~ m[^file://] ) {
		my $path = $url;
		$path =~ s[^file://][];
		$rss->parsefile($path) or return undef;
	}
	else {
		my $ua = LWP::UserAgent->new(timeout => 5);
		$ua->env_proxy;
		my $response = $ua->get($url);
		return undef unless $response->is_success();
		my $rss_doc = $response->content();

		$rss->parse($rss_doc) or return undef;
	}

	my %feed = (
		title		=> $rss->{channel}{title},
		link		=> $rss->{channel}{link},
		description	=> $rss->{channel}{description},
		items		=> [ ],
	);

	foreach my $item ( @{ $rss->{items} } ) {
		push @{ $feed{items} }, MusicBrainz::Server::NewsFeed::Item->new($item);
	}

	$self->{feed} = \%feed;

	# Cache all feed data.
	#
	$self->_StoreInCache();

	return 1;
}

sub _LoadFromCache()
{
	my $self = shift;
	my $key = 'newsfeed-' . $self->{url};

	return 0 if $self->{update_interval} == 0;

	$self->{feed} = MusicBrainz::Server::Cache->get($key) or return 0;

	return 1; # feed was successfully retrieved from the cache
}

sub _StoreInCache()
{
	my $self = shift;
	my $key = 'newsfeed-' . $self->{url};

	return if $self->{update_interval} == 0;

	MusicBrainz::Server::Cache->set(
								$key, $self->{feed}, $self->{update_interval});
}


# Returns a list of MusicBrainz::Server::NewsFeed::Item objects.
#
sub GetItems
{
	my $self = shift;

	croak "No parameter allowed" if @_;

	# Feed not initialized. That probably means it wasn't available.
	#
	my $feed = $self->{feed} or return ( );

	# Default is to return all items. The max_items config value overrides.
	#
	my $max_items = @{ $feed->{items} };
	$max_items = $self->{max_items} if defined $self->{max_items};

	# Create a filter to remove all entries that don't match (white list).
	#
	my $filter_categories = $self->{categories};
	my %filter = map { $_ => 1 } @$filter_categories;

	my @items;
	foreach my $item ( @{ $feed->{items} } ) {
		last if @items >= $max_items;

		next if defined $item->GetCategory() and @$filter_categories > 0
				and not $filter{ $item->GetCategory() };

		push @items, $item;
	}

	return @items;
}

sub GetTitle { $_[0]->{feed}{title} };
sub GetLink { $_[0]->{feed}{link} };
sub GetDescription { $_[0]->{feed}{description} };


package MusicBrainz::Server::NewsFeed::Item;

use Date::Calc qw( Mktime Decode_Month );
use POSIX qw( strftime );

sub new
{
	my $proto = shift;
	my $item = shift;
	my $class = ref($proto) || $proto;

	my $self = {
		item => $item,
	};

	return bless($self, $class);
}

sub GetTitle { $_[0]->{item}{title} };
sub GetLink { $_[0]->{item}{link} };
sub GetDescription { $_[0]->{item}{description} };
sub GetCategory { $_[0]->{item}{dc}{subject} || $_[0]->{item}{category} };

sub GetDate
{
	my $self = shift;
	my ($year, $month, $day, $hour, $minute, $second, $sign, $zhour, $zminute);

	my $str = $self->{item}{dc}{date};

	if ( $str ) {
		# RSS 1.0 pattern
		#
		($year, $month, $day, $hour, $minute, $second,
			$sign, $zhour, $zminute) =
				$str =~ m/^
							(\d{4})-(\d\d)-(\d\d)
							T(\d\d):(\d\d):(\d\d)
							([-+])(\d\d):(\d\d)
						$/x
			or return undef;
	}
	else {
		$str = $self->{item}{pubDate};

		# RSS 2.0 pattern
		#
		($day, $month, $year, $hour, $minute, $second,
			$sign, $zhour, $zminute) =
				$str =~ m/^
						...,\ (\d\d)\ (...)\ (\d{4})
						\ (\d\d):(\d\d):(\d\d)
						\ ([-+])(\d\d)(\d\d)
					$/x
			or return undef;

			$month = Decode_Month($month) if $month =~ m/[a-z]/i;
	}

	my $time = Mktime($year, $month, $day, $hour, $minute, $second);

	if ( $sign eq '-' ) {
		$time = $time + ($zhour*60*60 + $zminute*60);
	}
	else {
		$time = $time - ($zhour*60*60 + $zminute*60);
	}

	return $time;
};

sub GetDateTimeString
{
	my $self = shift;
	my $datetime = $self->GetDate();

	return undef unless $datetime;

	return strftime("%Y-%m-%d %H:%M GMT", localtime($datetime));
}

sub GetDateString
{
	my $self = shift;
	my $datetime = $self->GetDate();

	return undef unless $datetime;

	return strftime("%Y-%m-%d", localtime($datetime));
}

1;
