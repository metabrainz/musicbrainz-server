#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#	MusicBrainz -- the open music metadata database
#
#	Copyright (C) 2001 Robert Kaye
#
#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to the Free Software
#	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#	$Id$
#____________________________________________________________________________

package Sql;

use vars qw(@ISA @EXPORT);
@ISA	= @ISA	  = '';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use Carp qw(cluck croak carp);
use utf8 ();

sub new
{
	my ($type, $dbh) = @_;
	my $this = {};

	$this->{DBH} = $dbh;
	$this->{Quiet} = 0;

	bless $this, ref($type) || $type;
}

sub Quiet
{
	my ($this, $q) = @_;

	$this->{Quiet} = $q;
}

# Allow one auto commit transaction!
sub AutoCommit
{
	my ($this) = @_;
	return carp('$sql->AutoCommit called inside a transaction')
		if not $this->{DBH}{AutoCommit};
    cluck('$sql->AutoCommit called twice')
        if $this->{auto_commit_next_statement};
	$this->{auto_commit_next_statement} = 1;
}

sub Quote
{
	my ($this, $data) = @_;
	my $r = $this->{DBH}->quote($data);
	utf8::downgrade($r);
	$r;
}

sub Select
{
	my ($this, $query, @params) = @_;
	my ($ret, $t);

	my $prepare = (@params ? "prepare_cached" : "prepare");

	$ret = eval
	{
		my $tt = Sql::Timer->new($query, \@params);
		$this->{STH} = $this->{DBH}->$prepare($query);
		$ret = $this->{STH}->execute(@params);

		return $this->{STH}->rows;
	};
	if ($@)
	{
		my $err = $@;

		$this->{STH}->finish;
		$this->{ERR} = $this->{DBH}->errstr;
		cluck("Failed query:\n	'$query'\n	(@params)\n$err\n")
			unless ($this->{Quiet});
		die $err;
	}
	return $ret;
}

sub Finish
{
	my ($this) = @_;

	$this->{STH}->finish if $this->{STH};
}

sub Rows
{
	my ($this) = @_;

	$this->{STH}->rows;
}

sub NextRow
{
	my ($this) = @_;

	return $this->{STH}->fetchrow_array;
}

sub NextRowRef
{
	my ($this) = @_;

	return $this->{STH}->fetch;
}

sub NextRowHashRef
{
	my ($this) = @_;

	return $this->{STH}->fetchrow_hashref;
}

sub GetError
{
	my ($this) = @_;

	return $this->{ERR};
}

sub Do
{
	my ($this, $query, @params) = @_;
	my $ret;

	if ($this->{DBH}{AutoCommit})
	{
		# We're not in a transaction.  ->AutoCommit should be true.
		# (Side-effect: clear ->AutoCommit).
		delete $this->{auto_commit_next_statement}
			or croak '$sql->Do called with neither $sql->Begin nor $sql->AutoCommit';
	} else {
		# We are in a transaction.	Check that ->AutoCommit is false.
		not $this->{auto_commit_next_statement}
			or croak '$sql->Do called with both $sql->Begin and $sql->AutoCommit';
	}

	my $prepare = (@params ? "prepare_cached" : "prepare");

	$ret = eval
	{
		my $tt = Sql::Timer->new($query, \@params);
		utf8::downgrade($query);
		my $sth = $this->{DBH}->$prepare($query);
		utf8::downgrade($_) for @params;
		$sth->execute(@params);
	};
	if ($@)
	{
		my $err = $@;

		$this->{ERR} = $this->{DBH}->errstr;
		cluck("Failed query:\n	'$query'\n	(@params)\n$err\n")
			unless ($this->{Quiet});
		die $err;
	}
	return 0+$ret;
}

sub GetSingleRow
{
	my ($this, $tab, $cols, $where) = @_;
	my (@row, $query, $count);

	$query = "select " . join(", ", @$cols) . " from $tab";
	if (scalar(@$where) > 0)
	{
		for($count = 0; scalar(@$where) > 1; $count++)
		{
			if ($count == 0)
			{
				$query .= " where ";
			}
			else
			{
				$query .= " and ";
			}
			$query .= (shift @$where) . " = " .	(shift @$where);
		}
	}
	if ($this->Select($query))
	{
		@row = $this->NextRow;
		$this->Finish;

		return @row;
	}
	return undef;
}

# This function is just like GetSingleRow, but the first pair or
# where clause items is compared with ILIKE, and not a simple =
sub GetSingleRowLike
{
	my ($this, $tab, $cols, $where) = @_;
	my (@row, $query, $count);

	$query = "select " . join(", ", @$cols) . " from $tab";
	if (scalar(@$where) > 0)
	{
		for($count = 0; scalar(@$where) > 1; $count++)
		{
			if ($count == 0)
			{
				$query .= " where " . (shift @$where) . " ilike " .
					(shift @$where);
			}
			else
			{
				$query .= " and " . (shift @$where) . " = " .
					(shift @$where);
			}
		}
	}
	if ($this->Select($query))
	{
		@row = $this->NextRow;
		$this->Finish;

		return @row;
	}
	return undef;
}

sub GetLastInsertId
{
	my ($this, $table) = @_;
	$this->SelectSingleValue("SELECT CURRVAL(?)", $table . "_id_seq");
}

sub GetSingleColumn
{
	my ($this, $tab, $col, $where) = @_;
	my (@row, $query, $count, @col);

	$query = "select $col from $tab";
	if (scalar(@$where) > 0)
	{
		for($count = 0; scalar(@$where) > 1; $count++)
		{
			if ($count == 0)
			{
				$query .= " where ";
			}
			else
			{
				$query .= " and ";
			}
			$query .= (shift @$where) . " = " .	(shift @$where);
		}
	}
	if ($this->Select($query))
	{
		while(@row = $this->NextRow)
		{
			push @col, $row[0];
		}
		$this->Finish;

		return @col;
	}
	return ();
}

sub GetSingleColumnLike
{
	my ($this, $tab, $col, $where) = @_;
	my (@row, $query, $count, @col);

	$query = "select $col from $tab";
	if (scalar(@$where) > 0)
	{
		for($count = 0; scalar(@$where) > 1; $count++)
		{
			if ($count == 0)
			{
				$query .= " where " . (shift @$where) . " ilike " .
					(shift @$where);
			}
			else
			{
				$query .= " and " . (shift @$where) . " = " .
					(shift @$where);
			}
		}
	}
	if ($this->Select($query))
	{
		while(@row = $this->NextRow)
		{
			push @col, $row[0];
		}
		$this->Finish;

		return @col;
	}
	return ();
}

sub Begin
{
	my $this = $_[0];
	carp '$sql->Begin called while $sql->AutoCommit still active'
		if delete $this->{auto_commit_next_statement};
	croak '$sql->Begin called while already in a transaction'
        if not $this->{DBH}{AutoCommit};
	$this->{DBH}->{AutoCommit} = 0;
}

sub Commit
{
	my $this = $_[0];

	croak '$sql->Commit called without $sql->Begin'
		if $this->{DBH}->{AutoCommit};

	my $ret = eval
	{
		my $rv = $this->{DBH}->commit;
		cluck("Commit failed") if ($rv eq '' && !$this->{Quiet});
		return $rv;
	};

	if ($@)
	{
		my $err = $@;
		cluck($err) unless ($this->{Quiet});
		eval { $this->Rollback };
		$this->{DBH}{AutoCommit} = 1;
		die $err;
	}

	$this->{DBH}{AutoCommit} = 1;
	return $ret;
}

sub Rollback
{
	my $this = $_[0];

	croak '$sql->Rollback called without $sql->Begin'
		if $this->{DBH}->{AutoCommit};

	my $ret = eval
	{
		my $rv = $this->{DBH}->rollback;
		cluck("Rollback failed") if ($rv eq '' && !$this->{Quiet});
		return $rv;
	};

    $this->{DBH}{AutoCommit} = 1;

	if ($@)
	{
		my $err = $@;
		cluck($err) unless ($this->{Quiet});
		die $err;
	}

	return $ret;
}

# AutoTransaction: call back the given code reference,
# automatically applying a Begin/Commit/Rollback around it
# if required (i.e. if we are not already in a transaction).
# Calling context is preserved.	 Exceptions may be thrown.

sub AutoTransaction
{
	my ($self, $sub) = @_;
	# If we're already in a transaction, just run the code.
	return &$sub if not $self->{DBH}{AutoCommit};

	# Otherwise, Begin, run the code, and Commit.  Rollback if anything
	# false.  Always leave the transaction closed.
	my ($r, @r);
	my $w = wantarray;

	local $@;
	eval {
		$self->Begin;

		@r = &$sub() if $w;
		$r = &$sub() if defined $w and not $w;
		&$sub() if not defined $w;

		$self->Commit;
		1;
	} or do {
		my $e = $@;
		eval { $self->Rollback };
		die $e;
	};

	($w ? @r : $r);
}

# The "Select*" methods.  All these methods accept ($query, @args) parameters,
# run the given SELECT query using prepare_cached, retrieve the required data,
# and then "finish" the statement handle.

# Run a SELECT query.  Depending on the number of resulting rows:
# 0 rows: return "undef".
# >1 row: raise an error.
# 1 row: return a reference to a hash containing the row data.

sub SelectSingleRowHash
{
	my ($this, $query, @params) = @_;

	my $row = eval
	{
		my $tt = Sql::Timer->new($query, \@params);
		my $sth = $this->{DBH}->prepare_cached($query);
		my $rv = $sth->execute(@params)
			or die;
		my $firstRow = $sth->fetchrow_hashref;
		my $nextRow = $sth->fetchrow_hashref
			if $firstRow;
		$sth->finish;
		die "Query in SelectSingleRowHash returned more than one row"
			if $nextRow;
		$firstRow;
	};

	return $row unless $@;

	my $err = $@;
	$this->{ERR} = $this->{DBH}->errstr;
	cluck("Failed query:\n	'$query'\n	(@params)\n$err\n")
		unless ($this->{Quiet});
	die $err;
}

# Run a SELECT query.  Depending on the number of resulting rows:
# 0 rows: return "undef".
# >1 row: raise an error.
# 1 row: return a reference to an array containing the row data.

sub SelectSingleRowArray
{
	my ($this, $query, @params) = @_;

	my $row = eval
	{
		my $tt = Sql::Timer->new($query, \@params);
		my $sth = $this->{DBH}->prepare_cached($query);
		my $rv = $sth->execute(@params)
			or die;
		my $firstRow = $sth->fetchrow_arrayref;
		my $nextRow = $sth->fetchrow_arrayref
			if $firstRow;
		$sth->finish;
		die "Query in SelectSingleRowArray returned more than one row"
			if $nextRow;
		$firstRow;
	};

	return $row unless $@;

	my $err = $@;
	$this->{ERR} = $this->{DBH}->errstr;
	cluck("Failed query:\n	'$query'\n	(@params)\n$err\n")
		unless ($this->{Quiet});
	die $err;
}

# Run a SELECT query.  Depending on the number of resulting columns:
# >1 column (and at least one row): raise an error.
# otherwise: return a reference to an array containing the column data.

sub SelectSingleColumnArray
{
	my ($this, $query, @params) = @_;

	my $col = eval
	{
		my $tt = Sql::Timer->new($query, \@params);
		my $sth = $this->{DBH}->prepare_cached($query);
		my $rv = $sth->execute(@params)
			or die;

		my @vals;

		for (;;)
		{
			my @row	 = $sth->fetchrow_array
				or last;
			die unless @row == 1;
			push @vals, $row[0];
		}

		$sth->finish;

		\@vals;
	};

	return $col unless $@;

	my $err = $@;
	$this->{ERR} = $this->{DBH}->errstr;
	cluck("Failed query:\n	'$query'\n	(@params)\n$err\n")
		unless ($this->{Quiet});
	die $err;
}

# Run a SELECT query.  Must return either no data (return "undef"), or exactly
# one row, one column (return that value).

sub SelectSingleValue
{
	my ($this, $query, @params) = @_;
	my $row = $this->SelectSingleRowArray($query, @params);
	$row or return undef;

	return $row->[0] unless @$row != 1;

	cluck("Failed query:\n	'$query'\n	(@params)\nmore than one column\n")
		unless ($this->{Quiet});
	die "Query in SelectSingleValue returned more than one column";
}

# Run a SELECT query.  Return a reference to an array of rows, where each row
# is a reference to an array of columns.

sub SelectListOfLists
{
	my ($this, $query, @params) = @_;

	my $data = eval
	{
		my $tt = Sql::Timer->new($query, \@params);
		my $sth = $this->{DBH}->prepare_cached($query);
		my $rv = $sth->execute(@params)
			or die;

		my @vals;

		for (;;)
		{
			my @row	 = $sth->fetchrow_array
				or last;
			push @vals, \@row;
		}

		$sth->finish;

		\@vals;
	};

	return $data unless $@;

	my $err = $@;
	$this->{ERR} = $this->{DBH}->errstr;
	cluck("Failed query:\n	'$query'\n	(@params)\n$err\n")
		unless ($this->{Quiet});
	die $err;
}

# Run a SELECT query.  Return a reference to an array of rows, where each row
# is a reference to a hash of the column data.

sub SelectListOfHashes
{
	my ($this, $query, @params) = @_;

	my $data = eval
	{
		my $tt = Sql::Timer->new($query, \@params);
		my $sth = $this->{DBH}->prepare_cached($query);
		my $rv = $sth->execute(@params)
			or die;

		my @vals;

		for (;;)
		{
			my $row = $sth->fetchrow_hashref
				or last;
			push @vals, $row;
		}

		$sth->finish;

		\@vals;
	};

	return $data unless $@;

	my $err = $@;
	$this->{ERR} = $this->{DBH}->errstr;
	cluck("Failed query:\n	'$query'\n	(@params)\n$err\n");
	die $err;
}

################################################################################

package Sql::Timer;

use Time::HiRes qw( gettimeofday tv_interval );

sub new
{
	# Comment this out if you actually want to log all/slow queries
	return;

	my ($class, $sql, $args) = @_;

	#printf STDERR "Starting SQL: \"%s\" (%s)\n",
	#	 $sql, join(", ", @$args);

	bless {
		SQL => $sql,
		ARGS => $args,
		CALLER => [ caller(1) ],
		T0 => [ gettimeofday ],
	}, ref($class) || $class;
}

sub DESTROY
{
	my $self = shift;
	my $t = tv_interval($self->{T0});
	$self->{SQL} =~ s/\s+/ /sg;

	# Uncomment this if you're only interested in queries which take longer
	# than $somelimit
	#return if $t < 0.1;

	local $" = ", ";
	printf STDERR "SQL: %6.2fs \"%s\" (%s)\n",
		$t,
		$self->{SQL},
		join(", ", @{ $self->{ARGS} }),
		;
}

1;
# eof Sql.pm
