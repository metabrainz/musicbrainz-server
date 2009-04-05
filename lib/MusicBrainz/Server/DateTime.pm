#!/usr/bin/perl -w
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

package MusicBrainz::Server::DateTime;

sub parse_datetime
{
	# This component accepts a list of date-time strings, and parses each one into
	# a time value (in time() format).  A set of parsing options can be specified,
	# which will apply to all the parses.

	require UserPreference;
	my $fmt = UserPreference::get('datetimeformat');
	my $tz = UserPreference::get('timezone');

	my $uk_format = 1;
	$uk_format = 0 if $fmt =~ / %m .* %d /x;

	# Allow overrides by passing a hash reference as the first parameter.
	my %options;
	if (@_ and ref($_[0]) eq "HASH")
	{
		my $opts = shift;
		$fmt = $opts->{"datetimeformat"} if $opts->{"datetimeformat"};
		$tz = $opts->{"tz"} if $opts->{"tz"};
		delete @$opts{qw( datetimeformat tz )};
		%options = %$opts;
	}

	%options = (
		# defaults, which the options can override
		UK			=> $uk_format,
		WHOLE		=> 1,
		VALIDATE	=> 1,
		# overrides, and other options (e.g. PREFER_PAST or PREFER_FUTURE)
		%options,
	);

	require POSIX;
	require Time::ParseDate;

	my @r = eval
	{
		local $ENV{TZ};
		$ENV{TZ} = $tz;
		POSIX::tzset();

		map {
			scalar Time::ParseDate::parsedate($_, %options)
		} @_;
	};

	my $err = $@;
	POSIX::tzset();
	die $err if $err;

	#my @str = map { defined() ? scalar(gmtime $_) : undef } @r;
	#print STDERR Data::Dumper->Dump([ \%options, \@_, \@r, \@str ],[ '*options', '*_', '*r', '*str' ]);

	return $r[-1] unless wantarray;
	return(@r);
}

sub format_datetime
{
	# This component accepts a list of absolute times and converts each one to the
	# user's preferred date/time format, in their preferred time zone.

	# The input times can be in one of two formats: just an integer (seconds since
	# the epoch), or in Postgres format: "2003-01-25 22:06:54.82141+00" (in which
	# case, the seconds decimal point and everything following it will be
	# ignored).  So in this case, make sure that the time values you're passing in
	# are in UTC.

	my ($fmt, $tz);

	# Allow overrides by passing a hash reference as the first parameter.
	if (@_ and ref($_[0]) eq "HASH")
	{
		my $opts = shift;
		$fmt = $opts->{"datetimeformat"} if $opts->{"datetimeformat"};
		$tz = $opts->{"tz"} if $opts->{"tz"};
	}

	require POSIX;

	my @r = eval
	{
		local $ENV{TZ};

		# Convert any stringy times into integers
		$ENV{TZ} = 'UTC';
		POSIX::tzset();

		for (@_)
		{
			my @bits = /\A(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)\b/;

			if (@bits)
			{
				$bits[0] -= 1900;
				--$bits[1];
				$_ = POSIX::mktime(reverse @bits);
			}
		}

		# Now convert the integers to the local formatted time
		$ENV{TZ} = $tz;
		POSIX::tzset();

		my @tzn = POSIX::tzname();
		my @fmt = ($fmt, $fmt);
		for (0,1) { $fmt[$_] =~ s/%Z/$tzn[$_]/g }

		map {
			my @l = localtime $_;
			POSIX::strftime($fmt[$l[8]], localtime($_));
		} @_;
	};

	my $err = $@;
	POSIX::tzset();
	die $err if $err;

	return $r[-1] unless wantarray;
	return(@r);
}

sub format_datetime_since
{
	# This component accepts a list of absolute times and converts each one to the
	# user's preferred date/time format, in their preferred time zone.

	# The input times can be in one of two formats: just an integer (seconds since
	# the epoch), or in Postgres format: "2003-01-25 22:06:54.82141+00" (in which
	# case, the seconds decimal point and everything following it will be
	# ignored).  So in this case, make sure that the time values you're passing in
	# are in UTC.

    eval {
        require Time::Duration;
    };
    return format_datetime($_[0]) if ($@);

	return make_duration_cute(time() - $_[0]) if ($_[0] =~ /^\d+$/);

	require UserPreference;
	my $fmt = UserPreference::get('datetimeformat');
	my $tz = UserPreference::get('timezone');

	# Allow overrides by passing a hash reference as the first parameter.
	if (@_ and ref($_[0]) eq "HASH")
	{
		my $opts = shift;
		$fmt = $opts->{"datetimeformat"} if $opts->{"datetimeformat"};
		$tz = $opts->{"tz"} if $opts->{"tz"};
	}

	require POSIX;

	my $r = eval
	{
		local $ENV{TZ};

		# Convert any stringy times into integers
		$ENV{TZ} = 'UTC';
		POSIX::tzset();

		my $seconds = 0;
		for (@_)
		{
			my @bits = /\A(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)\b/;
			
			if (@bits)
			{
				$bits[0] -= 1900;
				--$bits[1];
				$seconds = POSIX::mktime(reverse @bits);
			}
		}

		# Now convert the integers to the local formatted time
		$ENV{TZ} = $tz;
		POSIX::tzset();

		return "" if (!$seconds);

	    make_duration_cute(time() - $seconds);
	};

	my $err = $@;
	POSIX::tzset();
	die $err if $err;

	return $r;
}

sub format_datetime_until
{
	# This component accepts a list of absolute times and converts each one to the
	# user's preferred date/time format, in their preferred time zone.

	# The input times can be in one of two formats: just an integer (seconds since
	# the epoch), or in Postgres format: "2003-01-25 22:06:54.82141+00" (in which
	# case, the seconds decimal point and everything following it will be
	# ignored).  So in this case, make sure that the time values you're passing in
	# are in UTC.

    eval {
        require Time::Duration;
    };
    return format_datetime($_[0]) if ($@);

	require UserPreference;
	my $fmt = UserPreference::get('datetimeformat');
	my $tz = UserPreference::get('timezone');

	# Allow overrides by passing a hash reference as the first parameter.
	if (@_ and ref($_[0]) eq "HASH")
	{
		my $opts = shift;
		$fmt = $opts->{"datetimeformat"} if $opts->{"datetimeformat"};
		$tz = $opts->{"tz"} if $opts->{"tz"};
	}

	require POSIX;

	my $r = eval
	{
		local $ENV{TZ};

		# Convert any stringy times into integers
		$ENV{TZ} = 'UTC';
		POSIX::tzset();

		my $seconds = 0;
		for (@_)
		{
			my @bits = /\A(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)\b/;
			
			if (@bits)
			{
				$bits[0] -= 1900;
				--$bits[1];
				$seconds = POSIX::mktime(reverse @bits);
			}
		}

		# Now convert the integers to the local formatted time
		$ENV{TZ} = $tz;
		POSIX::tzset();

		return "" if (!$seconds);

	    "in " . Time::Duration::duration($seconds - time(), 1);
	};

	my $err = $@;
	POSIX::tzset();
	die $err if $err;

	return $r;
}

sub make_duration_cute
{
	my ($dur) = @_;

	return "just now" if ($dur < 10); 

	return Time::Duration::duration($dur, 1) . " ago";
}

sub last_update
{
	my ($t) = @_;

	return undef if (!$t);
	return format_datetime_since($t);
}

1;
# eof DateTime.pm
