
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2004 Robert Kaye
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

use strict;

use HTML::Mason::ApacheHandler;
use HTML::Mason;

package MusicBrainz::Server::Mason;

use Apache::Constants qw( DECLINED NOT_FOUND );

sub preload_files
{
	my %files;

	my $len = length(&DBDefs::HTDOCS_ROOT);
	my $recurse = sub {
		my ($dir, $patt, $norec) = @_;
		my $fulldir = &DBDefs::HTDOCS_ROOT . $dir;

		# Find files using the shell.  This is to avoid loading File::Find,
		# which seems to be a "fat" module.
		my $maxdepth = ($norec ? "-maxdepth 1" : "");
		open(my $pipe, "cd $fulldir && find . $maxdepth -type f -print0 |") or die $!;
		local $/ = chr(0);

		while (<$pipe>)
		{
			next if m[/CVS/];
			next unless m[^\./htdocs/comp/] or m[\.(html|inc)\x00];
			chomp;
			s[^\./][];
			$files{"$_[0]/$_"} = 1;
		}

		close $pipe;
	};

	&$recurse("", qr/\.(html|inc)$/, 1);
	&$recurse("/comp", qr/^/);

	for my $t (qw(
		/bare
		/cdi
		/edit
		/freedb
		/mod
		/news
		/user
		/products
		/search
		/show
	)) {
		&$recurse($t,  qr/\.(html|inc)$/);
	}

	# Preloading seems to sometimes forget to import '$r'.  This saves
	# us having to declare '$r' in whichever component happens to complain at
	# server startup time.
	{
		package MusicBrainz::Server::ComponentPackage;
		use vars '$r';
	}

	printf STDERR "Preloading %d components\n", scalar keys %files;
	[ sort keys %files ];
}

sub get_handler
{
	# The in_package value here is the default, but it's worth
	# stating that we *depend* upon that default.
	my $compiler = HTML::Mason::Compiler::ToObject->new(
		default_escape_flags=> 'h',
		in_package			=> "MusicBrainz::Server::ComponentPackage",
	);

	my %opts = (
		compiler			=> $compiler,
		comp_root			=> &DBDefs::HTDOCS_ROOT,
		data_dir			=> &DBDefs::MASON_DIR,
		apache_status_title	=> __PACKAGE__." status",
		error_mode			=> (&DBDefs::DB_STAGING_SERVER ? "output" : "fatal"),
	);
	$opts{preloads} = preload_files() if &DBDefs::PRELOAD_FILES;
	my $handler = HTML::Mason::ApacheHandler->new(%opts);

	# Install our minimal HTML encoder as the default.  This leaves
	# top-bit-set characters alone.
	$handler->interp->set_escape( h => \&MusicBrainz::Server::Validation::encode_entities );
	# Mason's handling of multiple escapes in ambiguous, so |uh and |hu are
	# out.  And |u on its own is usually the wrong thing to do.
	$handler->interp->remove_escape('u');

	my $u = Apache->server->uid;
	my $g = Apache->server->gid;

	if (($> != $u or $) != $g) and ($>==0 or $<==0))
	{
		# Running as root?  "chown" MASON_DIR to the Apache user and group
		# we're going to be serving requests under.
		# Mason claims to do this itself, but it doesn't seem to work :-(

		# This used to be done all in-process using File::Find; but doing it
		# this way is actually more efficient, because then we don't have to
		# bloat ourselves up with File::Find.
		system "chown", "-R", "$u:$g", &DBDefs::MASON_DIR;
	}

	$handler;
}

our $ah = get_handler();

sub handler
{
    my ($r) = @_;

	{
		my $uri = $r->uri;
		return NOT_FOUND if $uri =~ m[/comp/];
		return NOT_FOUND if $uri =~ /\.inc$/;
	}

    return DECLINED if (!defined $r->content_type);
    return DECLINED if $r->content_type && $r->content_type !~ m[^text/html\b]io;

    package MusicBrainz::Server::ComponentPackage;

	# Make these available to all components:
	use MusicBrainz::Server::Validation qw( encode_entities );
	use URI::Escape qw( uri_escape );
	use MusicBrainz::Server::Replication ':replication_type';

    use vars qw(%session %pnotes %cookies);
    untie %session;
    %session = ();
    %pnotes = ();
    %cookies = ();

	{
		my $req = Apache::Request->instance($r);
		$pnotes{'ispopup'} = ($req->param("ispopup") ? 1 : "");
	}

    use CGI::Cookie ();
    %cookies = CGI::Cookie->parse($r->header_in('Cookie'));
	$_ = $_->value for values %cookies;

    my $tied = undef;

    if (my $c = $cookies{ &DBDefs::SESSION_COOKIE })
    {
	    my $mod = &DBDefs::SESSION_HANDLER;
	    eval "require $mod"; 
	    eval "import $mod";
        $tied = eval
		{
			tie %session, &DBDefs::SESSION_HANDLER, $c, &DBDefs::SESSION_HANDLER_ARGS;
		};
    }

	# Drop the session if expired
	if ($tied and $session{expire} and time() > $session{expire})
	{
		UserStuff->EnsureSessionClosed;
	}

	if (my $ipmask = $session{'ipmask'})
	{
		my $my_ip = $r->connection->remote_ip;

		if ($ipmask ne $my_ip)
		{
			$tied = undef;
			untie %session;
			UserStuff->ClearSessionCookie;
		}
	}

	# If we're not logged in, try and log in now using the "permanent" cookie.
	# Note that the condition ("unless") isn't strictly required; it's a
	# minor optimisation.
	UserStuff->TryAutoLogin(\%cookies)
		unless $tied and $session{uid};

    if ($tied)
    {
        $session{expire} = time() + &DBDefs::WEB_SESSION_SECONDS_TO_LIVE;

		my $user = $session{user};
		if (defined $user and $user ne "")
		{
			use URI::Escape qw( uri_escape );
			$r->connection->user(uri_escape($user, '^A-Za-z0-9._-'));
		}

		$tied = undef;
    }

	if (my $st = MusicBrainz::Server::Mason::apply_rate_limit($r)) { return $st }

    my $ret = eval { $ah->handle_request($r) };
	my $err = $@;

    untie %session;

	die $err if $err ne "";

    $ret;
}

# Given the result of a RateLimit test ($t), return a response indicating that
# the client is making requests too fast.
sub rate_limited
{
	my ($r, $t) = @_;
	$r->status(Apache::Constants::HTTP_SERVICE_UNAVAILABLE());
	$r->headers_out->add("X-Rate-Limited", sprintf("%.1f %.1f %d", $t->rate, $t->limit, $t->period));
	$r->send_http_header("text/plain; charset=utf-8");
	unless ($r->header_only)
	{
		$r->print("Your requests are exceeding the allowable rate limit (" . $t->msg . ")\015\012");
		$r->print("Please slow down then try again.\015\012");
	}
	return Apache::Constants::OK();
}

# Given a key (optional - defaults to something sensible), tests to see if the
# client is making requests too fast.  If yes, generates an appropriate
# response and returns something true (an Apache status for the handler to
# return); if no, returns something false.
sub apply_rate_limit
{
	my ($r, $key) = @_;

	if (not defined $key)
	{
		$key = "mason ip=" . $r->connection->remote_ip;
	}

	use MusicBrainz::Server::RateLimit;
	if (my $test = MusicBrainz::Server::RateLimit->test($key))
	{
		return rate_limited($r, $test) || '0 but true';
	}

	return '';
}

1;
# eof Mason.pm
