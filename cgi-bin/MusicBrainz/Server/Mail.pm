#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
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

package MusicBrainz::Server::Mail;

use Encode qw( from_to );

sub format_address_line
{
	my ($class, $name, $address) = @_;
	$class->_quoted_string($name) . " <$address>";
}

sub _quoted_string
{
	my ($class, $string) = @_;
	return '""' if $string eq "";

	if ($string =~ /[\x00-\x1F\x7F-\xFF]/)
	{
		from_to($string, "utf-8", "MIME-Q");
		return $string;
	}

	return $string unless $string =~ /[^A-Za-z0-9]/;

	$string =~ s/"/\\"/g;
	qq["$string"];
}

sub _quoted_header
{
	my ($class, $string) = @_;

	if ($string =~ /[\x00-\x1F\x7F-\xFF]/)
	{
		from_to($string, "utf-8", "MIME-Q");
		return $string;
	}

	$string;
}

################################################################################
# MIME::Lite interface.
################################################################################

use base qw( MIME::Lite );

sub send
{
	my $self = shift;

	# TODO encode headers?

	my $fh = $self->open(@_) or die $!;
	$self->print($fh) or die $!;
	close $fh or die $!;
}

################################################################################
# Mail::Mailer -like interface.
# I wanted to use Mail::Mailer itself, but the main drawbacks I could see with
# it were (i) there was no means (in the 'smtp' mailer) to specify the
# envelope sender, and (ii) I'd rather not fork() if possible.
################################################################################

# Usage:
# my $mailer = $class->open($from, $to) or die;
# print $mailer "$headers\n\n$body\n";
# close $mailer or die;
# '$to' can be either a single address or an array ref to a list of them.

sub open
{
	my ($class, $from, $to) = @_;
	$to = [$to] unless ref($to) eq "ARRAY";
	@$to or return;

	# For debugging, you can spool all mail into a file, instead of actually sending it
	if (defined(my $spoolfile = &DBDefs::DEBUG_MAIL_SPOOL))
	{
		open(my $fh, ">>$spoolfile")
			or die $!;
		use Fcntl qw( :flock );
		flock($fh, LOCK_EX) or die $!;
		seek($fh, 0, 2) or die $!;
		print $fh "\n\cL\n";
		printf $fh "Mail spooled by %s line %d at %s\n",
			(caller)[0,2], scalar localtime;
		print $fh "MAIL FROM: $from\n";
		print $fh "RCPT TO: $_\n" for @$to;
		return $fh;
	}

	require Net::SMTP;
	my $smtp = Net::SMTP->new(&DBDefs::SMTP_SERVER)
		or return warn "Failed to open SMTP connection: $!";

	$smtp->mail($from)
		or return warn "SMTP 'mail' error: " . $smtp->message;

	for (@$to)
	{
		$smtp->to($_)
			or return warn "SMTP 'rcpt' ($_) error: " . $smtp->message;
	}

	$smtp->data
		or return warn "SMTP 'data' error: " . $smtp->message;

	use Symbol qw( gensym );
	my $fh = gensym;
	tie *$fh, 'MusicBrainz::Server::Mail::net_smtp_stream', $smtp;
	$fh;
}

package MusicBrainz::Server::Mail::net_smtp_stream;

sub TIEHANDLE
{
	my ($class, $smtp) = @_;
	bless [ $smtp ], $class;
}

sub PRINT
{
	my $self = shift;
	$self->[0]->datasend(@_);
}

sub PRINTF
{
	my $self = shift;
	my $fmt = shift;
	$self->[0]->datasend(sprintf $fmt, @_);
}

sub CLOSE
{
	my $self = shift;
	$self->[0]->dataend
		or warn "SMTP 'dataend' error: " . $self->[0]->message;
}

sub FILENO { fileno($_[0][0]) }

1;
# eof Mail.pm
