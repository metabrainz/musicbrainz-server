#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :

use strict;

use HTML::Mason::ApacheHandler ( args_method => 'mod_perl' );
use HTML::Mason; # brings in subpackages: Parser, Interp, etc.

package MusicBrainz::Server::Mason;

sub get_handler
{
	my $parser = HTML::Mason::Parser->new(
		default_escape_flags => 'h',
	);

	my $interp = HTML::Mason::Interp->new(
		parser				=> $parser,
		comp_root			=> &DBDefs::HTDOCS_ROOT,
		data_dir			=> &DBDefs::MASON_DIR,
		allow_recursive_autohandlers => undef,
		system_log_events	=> 'CACHE',
	);

	my $handler = HTML::Mason::ApacheHandler->new(
		interp => $interp,
	);

	my ($user, $group) = (&DBDefs::APACHE_USER, &DBDefs::APACHE_GROUP);

	my $uid = (getpwnam $user)[2];
	defined($uid) or die "No such user '$user'";

	my $gid = (getgrnam $group)[2];
	defined($gid) or die "No such group '$group'";

	if (my @files = $interp->files_written)
	{
		my $n = chown($uid, $gid, @files);
		warn "chown: $!" if $n != @files;
	}

	$handler;
}

our $ah = get_handler();

sub handler
{
    my ($r) = @_;

    # return "FORBIDDEN" for anyone trying to access comp directory
    return 403 if ($r->uri =~ m|^/comp/|);
    return -1 if (!defined $r->content_type);
    return -1 if $r->content_type && $r->content_type !~ m|^text/html|io;

    package HTML::Mason::Commands;
    use vars qw(%session);
    untie %session;
    %session = ();

    use CGI::Cookie ();
    my %cookies = CGI::Cookie->parse($r->header_in('Cookie'));

    my $tied;

    if (my $c = $cookies{'AF_SID'})
    {
        $tied = eval
		{
			use Apache::Session::File ();
			tie %session,
				'Apache::Session::File',
				$c->value,
			{
				Directory => &DBDefs::SESSION_DIR,
				LockDirectory => &DBDefs::LOCK_DIR,
			};
		};
    }

    if ($tied)
    {
        $session{expire} = time() + &DBDefs::WEB_SESSION_SECONDS_TO_LIVE;

		my $user = $session{user};
		if (defined $user and $user ne "")
		{
			$r->connection->user($user);
		}

		$tied = undef;
    }

    my $ret = eval { $ah->handle_request($r) };

    untie %session;

    $ret;
}

1;
# eof Mason.pm
