#!/usr/bin/perl -w
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

package MusicBrainz::Server::Database;

################################################################################
# Connection registration
################################################################################

our %connections;
our $_profile;

# Register all at once (hash of hashes)
sub register_all
{
	my $class = shift;
	my $all = shift;
	$class->start_register();
	$class->register($_, $all->{$_}) for keys %$all;
	$class->end_register();
}

# Start
sub start_register
{
	%connections = ();
}

# Register one (ID, hash)
sub register
{
	my ($class, $key, $info) = @_;
	return if not defined $info;

	my %entry;
	$entry{$_} = $info->{$_}
		for qw(
			database
			username
			password
			host
			port
		);
	$entry{key} = $key;

	bless \%entry, $class;
	$connections{$key} = \%entry;
}

# End
sub end_register
{
	();
}

sub profile
{
    my ($class, $profile) = @_;
    if (defined $profile) {
        $_profile = $profile;
    }
    return $_profile;
}

################################################################################
# Retrieve connections, etc
################################################################################

sub keys { keys %connections }
sub all { values %connections }

sub get
{
	my ($class, $key) = @_;
	$connections{$key};
}

sub modify
{
	my ($self, %modifiers) = @_;
	bless {
		%$self,
		%modifiers,
		key => undef,
	}, ref($self);
}

################################################################################
# Things to do with a connection
################################################################################

sub key			{ $_[0]{key} }
sub database	{ $_[0]{database} }
sub username	{ $_[0]{username} }
sub password	{ $_[0]{password} }
sub host		{ $_[0]{host} }
sub port		{ $_[0]{port} }

# Arguments required for DBI->connect
sub dbi_args
{
	my $self = shift;
	local $_;

	my $dsn = "DBI:Pg:dbname=" . $self->database;
	$dsn .= ";host=$_" if length($_ = $self->host);
	$dsn .= ";port=$_" if length($_ = $self->port);

	(
		$dsn,
		$self->username,
		$self->password,
		{ RaiseError => 1, PrintError => 0, AutoCommit => 1 },
	);
}

# Arguments required for "psql" etc
sub shell_args
{
	my $self = shift;
	my @args;

	push @args, "-h", $_ if length($_ = $self->host);
	push @args, "-p", $_ if length($_ = $self->port);
	push @args, "-U", $_ if length($_ = $self->username);
	# FIXME how to supply the password?
	warn "Don't know how to supply the password on the shell\n"
		if length($self->password);
	push @args, $self->database;

	return @args if wantarray;
	require String::ShellQuote;
	join " ", map { String::ShellQuote::shell_quote($_) } @args;
}

sub get_last_replication_date
{
    require MusicBrainz;
    my $mb = MusicBrainz->new;
    $mb->Login;
    my $sql = Sql->new($mb->{dbh});
    return $sql->SelectSingleValue("SELECT last_replication_date FROM replication_control");
}

1;
# eof Database.pm
