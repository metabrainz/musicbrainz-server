#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
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

package SearchEngine;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

{
    @ISA = qw( Exporter );
    @EXPORT = ();

    my @constants = qw(
	SEARCHRESULT_SUCCESS
	SEARCHRESULT_NOQUERY
	SEARCHRESULT_TIMEOUT
    );

    @EXPORT_OK = (@constants);

    %EXPORT_TAGS = (
	constants => \@constants,
    );

    my %all;
    @all{@$_} = () for values %EXPORT_TAGS;
    $EXPORT_TAGS{'all'} = [ keys %all ];

    () = (@ISA, @EXPORT, @EXPORT_OK, %EXPORT_OK);
}

use strict;
use DBDefs;
use Sql;
use ModDefs;
use Encode qw( encode decode );
use Carp qw( croak );
use MusicBrainz::Server::Validation qw( unaccent );

use constant SEARCHRESULT_SUCCESS => 1;
use constant SEARCHRESULT_NOQUERY => 2;
use constant SEARCHRESULT_TIMEOUT => 3;

use constant MAX_ANALYZE_WORDS => 20;
use constant MAX_QUERY_WORDS => 8;
use constant DEFAULT_SEARCH_TIMEOUT => 60;
use constant DEFAULT_SEARCH_LIMIT => 0;

sub new
{
    my $class = shift;
    my $dbh = shift;

    my $self = bless {
	dbh	=> $dbh,
	Table	=> "artist",
    }, $class;

    $self->Table(shift);

    my $sql = Sql->new($self->dbh);
    $self->{SQL} = $sql;

    return $self;
}

sub Table
{
    my ($self,$table) = @_;
    $self->{Table} = lc $table if defined $table;
    return $self->{Table};
}

sub Tokenize
{
    my $self  = shift;
    my $str = shift;

    # Note that tokenization is script-neutral (e.g. Latin, Arabic, Cyrillic
    # etc) apart from the treatment of apostrophes.  Non-Latin scripts are
    # /bound/ to have some equivalent to our apostrophe (i.e. a non-letter,
    # non-number character in the middle of a word).  These can be added
    # as we understand more about the generalised problem.

    $str = unaccent($str);
    # Always case insensitive
    $str = lc decode("utf-8", $str);

    # Apostrophes are removed; hence:
    # don't => dont
    # 'n' => n
    # 'quoted bit' => quoted,bit
    $str =~ tr/'//d;

    # Look for chains of letters/numbers
    my @words = $str =~ /([\pL\pN]+)/g;
    $_ = encode("utf-8", $_) for @words;

    my %seen = ();
    ++$seen{$_} for @words;
    return(\%seen, \@words) if wantarray;
    \%seen;
}

################################################################################
# Maintain the search engine indices.
################################################################################

sub AddWord
{
    my ($self, $word) = @_;

    my $id = $self->{SQL}->SelectSingleValue(
	"SELECT id FROM wordlist WHERE word = ?",
	$word,
    );
    return $id if $id;

    $self->{SQL}->Do("INSERT INTO wordlist (word) VALUES (?)", $word);
    return $self->{SQL}->GetLastInsertId('wordlist');
}

sub AddWordRefs
{
    my $self = shift;
    my ($object_id, $name, $remove_others) = @_;
    $name = join "\n", @$name if ref($name) eq "ARRAY";
    my @words = keys %{ $self->Tokenize($name) };

    # The word IDs we want to keep when we've finished (only applies if
    # $remove_others is true)
    my %word_ids;

    # Retrieve existing word IDs for this object in one hit so we don't keep
    # looking them up later
    my $existing_wordids = do {
	my $t = $self->{SQL}->SelectSingleColumnArray(
	    "SELECT wordid FROM $self->{Table}words WHERE $self->{Table}id = ?",
	    $object_id,
	);
	+{ map { $_ => 1 } @$t };
    };

    foreach (@words)
    {
        my $word_id = $self->AddWord($_);
        next if not defined $word_id;
	++$word_ids{$word_id};
	next if $existing_wordids->{$word_id};

	$self->{SQL}->SelectSingleValue(
	    "SELECT 1 FROM $self->{Table}words
    	    WHERE $self->{Table}id = ?
	    AND wordid = ?",
	    $object_id,
	    $word_id,
	) and next;

	$self->{SQL}->Do(
	    "INSERT INTO $self->{Table}words
    		($self->{Table}id, wordid)
     		VALUES (?, ?)",
	    $object_id,
	    $word_id,
	);
    }

    if ($remove_others)
    {
	if (keys %word_ids)
	{
	    my $qs = join ", ", ("?") x keys %word_ids;
	    $self->{SQL}->Do(
		"DELETE FROM $self->{Table}words WHERE $self->{Table}id = ? AND wordid NOT IN ($qs)",
		$object_id,
		keys %word_ids,
	    );
	} else {
	    # Not very likely
	    $self->{SQL}->Do(
		"DELETE FROM $self->{Table}words WHERE $self->{Table}id = ?",
		$object_id,
	    );
	}
    }
}

sub RemoveObjectRefs
{
    my ($self, $object_id) = @_;

    $self->{SQL}->Do(
	"DELETE FROM $self->{Table}words WHERE $self->{Table}id = ?",
	$object_id,
    );
}

sub RebuildIndex
{
    my $self = shift;
    my ($count, $written, $query, $total_rows, $start_time);

    $self->{SQL}->Begin();
    $self->{SQL}->Do("DELETE FROM " . $self->{Table} . "words");
    $self->{SQL}->Commit();

    # Make postgres analyze its foo to speed up the insertion
    $self->{SQL}->AutoCommit();
    $self->{SQL}->Do("VACUUM ANALYZE " . $self->{Table} . "words");

    $total_rows = $self->{SQL}->SelectSingleValue("SELECT COUNT(*) FROM $self->{Table}");

    my $block_size = 1000;
    for($count = 0;; $count += $block_size)
    {

        $written = 0;
        # Start a transaction
        eval
        {
            print STDERR "Start transaction for $count -> " . ($count + $block_size) . "\n";
            $self->{SQL}->Begin;

            $query = "SELECT id, name FROM $self->{Table}";
            if ($self->{Table} eq 'artist')
            {
                  $query .= " UNION SELECT artistalias.ref, artistalias.name FROM artistalias";
            }
            $query .= " LIMIT $block_size OFFSET $count";

            $start_time = time();
            if ($self->{SQL}->Select($query))
            {
                while ( my $row = $self->{SQL}->NextRowRef)
                {
                    #print STDERR "Adding words for $self->{Table} $row->[0]: $row->[1]\n";
                    $self->AddWordRefs(@$row);

                    if ($written > 0 && time() > $start_time &&
                       ($written % 100) == 0)
                    {
                         print STDERR $self->{Table} . " index added " .
                              ($written + $count) . " of $total_rows. (".
                              int(($written + $count) * 100 / $total_rows) .
                              "%, " .  int($written / (time() - $start_time)) .
                              " rows/sec)                \r";
                    }

                    $written++;
                }
            }
	    $self->{SQL}->Finish;

            print STDERR $self->{Table} . " index added " .
                         ($written + $count) . " of $total_rows. (".
                         int(($written + $count) * 100 / $total_rows) .
                         "%, " .  int($written / (time() - $start_time)) .
                         " rows/sec)                \r";

            # And commit all the changes
            $self->{SQL}->Commit;
            print STDERR "\nCommit transaction\n";
        };
        if ($@)
        {
            my $err = $@;
            $self->{SQL}->Rollback;
            print STDERR "\nIndex insert: $err";
        }

        # Make postgres analyze its foo to speed up the insertion
        print STDERR "Postgres: vacuum analyze WordList\n";
        $self->{SQL}->AutoCommit();
        $self->{SQL}->Do("VACUUM ANALYZE wordlist");

        print STDERR "Postgres: vacuum analyze " . $self->{Table} . "words\n";
        $self->{SQL}->AutoCommit();
        $self->{SQL}->Do("VACUUM ANALYZE " . $self->{Table} . "words");

        if ($written < $block_size)
        {
            last;
        }
    }
}

################################################################################
# Perform a search
################################################################################

# Do the search!

sub coalesce
{
    my $t = shift;

    while (not defined $t and @_)
    {
	$t = shift;
    }

    $t;
}

# oh god, please don't strike me down for the sins I am committing!
# (I hate !!! because their shitty name make things really HARD (or ugly)!)
# hint: svn blame SearchEngine.pm :)
sub HandleSpecialCases
{
    my ($self, $search) = @_;

    return "chkchkchk" if ($search eq '!!!' && $self->{Table} eq 'artist');

    return $search;
}

sub Search
{
    my ($self, %opts) = @_;
    
    my $search = coalesce($opts{'query'}, "");
    $self->{'limit'} = coalesce($opts{'limit'}, DEFAULT_SEARCH_LIMIT, 0);
    $self->{'timeout'} = coalesce($opts{'timeout'}, DEFAULT_SEARCH_TIMEOUT, 0);
    $self->{'vartist'} = coalesce($opts{'vartist'}, 0);

    $self->{RESULTTYPE} = undef;
    $self->{RESULTS} = [];
    $self->{RESIDX} = 0;

    $search = $self->HandleSpecialCases($search);

    my ($words, $wordchain) = $self->Tokenize($search);

    unless (keys %$words)
    {
	$self->{RESULTTYPE} = SEARCHRESULT_NOQUERY;
	return;
    }

    use DebugLog;
    if (my $d = DebugLog->open)
    {
        $d->stamp;
	$d->print(
	    "Tokenized query: "
	    . join(" ", map { "$_=$words->{$_}" } keys %$words)
	    . "\n"
	);
        $d->close;
    }

    my $sqlwords = $words;

    # If there are too many words, we'll search on only a few of them.
    if (keys(%$sqlwords) > MAX_ANALYZE_WORDS)
    {
	# Pick the longest words; they tend to be less common.
	my @w = sort { length($b) <=> length($a) } keys %$sqlwords;
	$sqlwords = +{
	    map {
		$w[$_] => $words->{ $w[$_] }
	    } 0 .. MAX_ANALYZE_WORDS-1
	};
    }

    if (my $d = DebugLog->open)
    {
        $d->stamp;
	$d->print(
	    "Analyze words: "
	    . join(" ", map { "$_=$sqlwords->{$_}" } keys %$sqlwords)
	    . "\n"
	);
        $d->close;
    }

    my $table = $self->Table;

    my $sql = Sql->new($self->dbh);
    my $counts = $sql->SelectListOfLists(
	"SELECT id, word, ${table}usecount
	FROM wordlist WHERE
	word IN (" . join(",", ("?") x scalar keys %$sqlwords) . ")",
	keys(%$sqlwords),
    );

    if (my $d = DebugLog->open)
    {
        $d->stamp;
	$d->printf("Word analysis: %12d  %6d  %s\n", @$_[0,2,1]) for @$counts;
	$d->close;
    }

    # If any words are missing, return an empty result set straight away.

    for my $word (keys %$sqlwords)
    {
	next if grep { $_->[1] eq $word } @$counts;

	$self->{RESULTTYPE} = SEARCHRESULT_SUCCESS;

	return;
    }

    # Now on to do the actual searching!

    @$counts = sort {
	$a->[2] <=> $b->[2]
    } @$counts;

    # Search on ay most this many words (least common first)
    splice(@$counts, MAX_QUERY_WORDS)
	if @$counts > MAX_QUERY_WORDS;

    if (my $d = DebugLog->open)
    {
        $d->stamp;
	$d->printf("Query for words: %12d  %6d  %s\n", @$_[0,2,1]) for @$counts;
	$d->close;
    }

    $sql->AutoCommit;
    $sql->Do("SET SESSION STATEMENT_TIMEOUT = " . int($self->{timeout}*1000))
    	if $self->{timeout};

    my $results = eval {
	local $sql->{Quiet} = 1;
	my @wordids = map { $_->[0] } @$counts;
	$sql->SelectListOfHashes(
	    $self->_GetQuery(\@wordids),
	)
    };

    my $err = $@;
    my $sqlerr = $sql->GetError;

    $sql->AutoCommit;
    $sql->Do("SET SESSION STATEMENT_TIMEOUT = DEFAULT");

    unless ($results)
    {
	if ($sql->is_timeout($sqlerr))
	{
	    $self->{RESULTTYPE} = SEARCHRESULT_TIMEOUT;
	    return;
	}

	die $err;
    }

    # Now we need to filter those results to check that they match all of the
    # other search terms
    my $namecol = $table . "name";

    @$results = grep {
	my $r = $_;
	my @t;

	my ($tokens, $c1) = $self->Tokenize($r->{$namecol});
	push @t, [ $tokens, $c1 ];
	my $fOK = not grep { ($tokens->{$_}||0) < $words->{$_} } keys %$words;

	# For artist search: if the artist name didn't match, also try the
	# sortname and any aliases.
	if ($table eq "artist")
	{
	    {
		($tokens, $c1) = $self->Tokenize($r->{'artistsortname'});
		push @t, [ $tokens, $c1 ];
		$fOK ||= not grep { ($tokens->{$_}||0) < $words->{$_} } keys %$words;
	    }

	    if ($r->{'numartistaliases'})
	    {
		require MusicBrainz::Server::Alias;
		my $al = MusicBrainz::Server::Alias->new($self->dbh, "ArtistAlias");
		my $aliases = $al->LoadFull($r->{'artistid'});

		for my $alias (@$aliases)
		{
		    ($tokens, $c1) = $self->Tokenize($alias->name);
		    push @t, [ $tokens, $c1 ];
		    $fOK ||= not grep { ($tokens->{$_}||0) < $words->{$_} } keys %$words;
		}
	    }
	}
	elsif ($table eq "label")
	{
	    if ($r->{'numlabelaliases'})
	    {
		require MusicBrainz::Server::Alias;
		my $al = MusicBrainz::Server::Alias->new($self->dbh, "labelalias");
		my $aliases = $al->LoadFull($r->{'labelid'});

		for my $alias (@$aliases)
		{
		    ($tokens, $c1) = $self->Tokenize($alias->name);
		    push @t, [ $tokens, $c1 ];
		    $fOK ||= not grep { ($tokens->{$_}||0) < $words->{$_} } keys %$words;
		}
	    }
	}

	$r->{'tokens'} = \@t if $fOK;

	$fOK;
    } @$results;

    # OK, that's got all the results matching all the search terms.
    # Now we need to order them.

    # Basically if we queried for "a b c" then "a b c" is the ideal match.
    # Having words in the title that we didn't query for should drop us down
    # the list.
    # Having the words not together in the specified order should drop us down
    # the list.

    # Interesting hack: map the encoded word IDs into characters (it doesn't
    # matter which ones exactly), then use String::Similarity to compare them
    require String::Similarity;

    my %used_char; my $next_char = 32;
    my $map_word_to_char = sub {
	my $word = $_[0];
	return $used_char{$word} if defined $used_char{$word};
	return($used_char{$word} = chr($next_char++));
    };

    my %wordids = map { $_->[1] => $_->[0] } @$counts;
    my $s0 = join "", map { &$map_word_to_char($_) } @$wordchain;

    for my $r (@$results)
    {
	my $q = $r->{'tokens'};
	my $bestsim = 0;

	for my $pair (@$q)
	{
	    my ($tokens, $chain) = @$pair;
	    my $s1 = join "", map { &$map_word_to_char($_) } @$chain;
	    my $sim = String::Similarity::fstrcmp($s0, $s1);
	    $bestsim = $sim if $sim > $bestsim;
	}

	$r->{'_similarity'} = $bestsim;
    }

    # Decode some strings into Unicode for sorting
    my @string_cols;
    $table eq "artist" and @string_cols = qw( artistsortname );
    $table eq "label" and @string_cols = qw( labelname );
    $table eq "album" and @string_cols = qw( albumname artistsortname );
    $table eq "track" and @string_cols = qw( trackname artistsortname albumname );
    $self->_DecodeStringColumns($results, \@string_cols);

    if ($table eq "artist")
    {
	@$results = sort {
	    $b->{'_similarity'} <=> $a->{'_similarity'}
		or
	    $a->{'_artistsortname_decoded'} cmp $b->{'_artistsortname_decoded'}
	} @$results;
    }
    elsif ($table eq "label")
    {
	@$results = sort {
	    $b->{'_similarity'} <=> $a->{'_similarity'}
		or
	    $a->{'_labelname_decoded'} cmp $b->{'_labelname_decoded'}
	} @$results;
    }
    elsif ($table eq "album")
    {
	@$results = sort {
	    $b->{'_similarity'} <=> $a->{'_similarity'}
		or
	    $a->{'_albumname_decoded'} cmp $b->{'_albumname_decoded'}
		or
	    $a->{'_artistsortname_decoded'} cmp $b->{'_artistsortname_decoded'}
	} @$results;
    }
    elsif ($table eq "track")
    {
	@$results = sort {
	    $b->{'_similarity'} <=> $a->{'_similarity'}
		or
	    $a->{'_trackname_decoded'} cmp $b->{'_trackname_decoded'}
		or
	    $a->{'_artistsortname_decoded'} cmp $b->{'_artistsortname_decoded'}
		or
	    $a->{'_albumname_decoded'} cmp $b->{'_albumname_decoded'}
	} @$results;
    }

    # Finally, limit the results if so requested.
    my $lim = $self->{'limit'};
    splice(@$results, $lim) if $lim and @$results > $lim;

    # Return the results
    $self->{RESULTTYPE} = SEARCHRESULT_SUCCESS;
    $self->{RESULTS} = $results;
}

sub _GetQuery
{
    my $self = shift;
    my $wordsref = shift;
    my @words = @$wordsref;
    my $table = $self->Table;
    my $wtable = $table . "words";
    my $idcol = $table . "id";
    my $numwords = scalar @words;

    my $where = join " AND ", map {
	"w$_.wordid = $words[$_-1]"
    } 1 .. $numwords;

    # Check to see if the query should be restricted to Various artists only
    $where .= " AND t.artist = " . &ModDefs::VARTIST_ID . " " 
       if ($self->{vartist} && $table eq 'album');

    my $from = "$wtable w1";
    $from .= "\n INNER JOIN $wtable w$_ ON w$_.$idcol = w${\($_-1)}.$idcol"
    	for 2 .. $numwords;
    $from .= "\n INNER JOIN $table t ON t.id = w$numwords.$idcol";

    # The second column in each case must be the name,
    # which will be re-tokenized and checked.

	return "
		SELECT	
		t.id			AS artistid,
		t.gid			AS artistgid,
		t.name			AS artistname,
		t.sortname		AS artistsortname,
		t.resolution	AS artistresolution,
		t.modpending	AS artistmp,
		COUNT(aa.id)	AS numartistaliases
		FROM $from
		LEFT JOIN artistalias aa ON aa.ref = t.id
		WHERE $where
		GROUP BY t.id, t.name, t.sortname, t.gid, t.resolution, t.modpending
	" if $table eq "artist";

	return "
		SELECT	
		t.id			AS labelid,
		t.gid			AS labelgid,
		t.name			AS labelname,
		t.labelcode		AS labelcode,
		t.resolution	AS labelresolution,
		t.modpending	AS labelmp,
		COUNT(aa.id)	AS numlabelaliases
		FROM $from
		LEFT JOIN labelalias aa ON aa.ref = t.id
		WHERE $where
		GROUP BY t.id, t.name, t.labelcode, t.gid, t.resolution, t.modpending
	" if $table eq "label";

	return "
		SELECT	
		t.id			AS albumid,
		t.gid			AS albumgid,
		t.name			AS albumname,
		m.tracks,
		m.discids,
		m.puids,
		m.firstreleasedate,
		a.id			AS artistid,
		a.gid			AS artistgid,
		a.name			AS artistname,
		a.sortname		AS artistsortname,
		a.resolution	AS artistresolution,
		t.modpending	AS albummp,
		a.modpending	AS artistmp
		FROM $from
		INNER JOIN artist a ON a.id = t.artist
		LEFT JOIN albummeta m ON m.id = t.id
		WHERE $where
	" if $table eq 'album';

	return "
		SELECT	
		t.id			AS trackid,
		t.gid			AS trackgid,
		t.name			AS trackname,
		t.length		AS tracklength,
	
		j.sequence		AS trackseq,
		a.id			AS artistid,
		a.name			AS artistname,
		a.sortname		AS artistsortname,
		a.resolution	AS artistresolution,
		al.id			AS albumid,
		al.gid			AS albumgid,
		al.name			AS albumname,
		t.modpending	AS trackmp,
		a.modpending	AS artistmp,
		al.modpending	AS albummp,
		j.modpending	AS albumjoinmp
		FROM $from
		INNER JOIN artist a ON a.id = t.artist
		INNER JOIN albumjoin j ON j.track = t.id
		INNER JOIN album al ON al.id = j.album
		WHERE $where
	" if $table eq "track";

	die;
}

sub _DecodeStringColumns
{
    my ($self, $data, $cols) = @_;

    my $eval = ' for my $row (@$data) { ';

    for my $col (@$cols)
    {
	$eval .= "
	\$row->{'_${col}_decoded'} = lc decode('utf-8', unaccent(\$row->{'$col'}));
	";
    }

    $eval .= ' } ';

    eval "$eval ; 1" or die $@;
}

# Methods to iterate over the found results, etc

sub Result
{
    my $self = shift;
    $self->{RESULTTYPE};
}

sub Finish
{
    my $self = shift;
    delete @$self{qw( RESULTTYPE RESULTS RESIDX )};
}

sub Rows
{
    my $self = shift;
    scalar @{ $self->{RESULTS} };
}

sub NextRow
{
    my $self = shift;
    $self->{RESULTS}[ $self->{RESIDX}++ ];
}

################################################################################
# Re-implementation of RebuildAllIndices.  Much much faster, but can only be
# used if there are no other writes (of artists/albums/tracks) being made to
# the database.  Also doesn't work solely within one transaction, so if
# interrupted you'll have only a partial search index.
################################################################################

sub RebuildAllIndices
{
    my $self = shift;
    my $sql = $self->{SQL};
    my $dbh = $sql->{dbh};

    require IO::File;
    my $fh_wordlist = IO::File->new_tmpfile or die $!;
    my $fh_artistwords = IO::File->new_tmpfile or die $!;
    my $fh_albumwords = IO::File->new_tmpfile or die $!;
    my $fh_trackwords = IO::File->new_tmpfile or die $!;

    # This will become a weakness at some point: cache the whole wordlist
    # in memory.  Maybe this will eventually become a DB_File or
    # something.
    my %words;
    my $nextwordid = 0;

    $| = 1 if -t;

    my $sub = sub {
	my ($query, $table, $fh_tablewords, $useindex) = @_;

	my $rows = $sql->SelectSingleValue(
	    "SELECT COUNT(*) FROM $table",
	);

	print localtime() . " : Processing query: $query (est. $rows rows)\n";
	$sql->Select($query) or die;

	my $lastid = 0;
	my @tokens;
	my $i = 0;

	my $flush = sub {
	    # @tokens is a list of hash references (tokenized names)
	    # $lastid is the ID to which they belong

	    # Unique list of words
	    my @words = keys %{ +{ map { %$_ } @tokens } };

	    # For each word, create an ID for it if necessary, then write
	    # its ID into $fh_tablewords

	    for my $word (@words)
	    {
		my $wordentry = $words{$word};

		unless ($wordentry)
		{
		    $wordentry = $words{$word} = [ ++$nextwordid, 0, 0, 0 ];
		    #print $fh_wordlist "$wordid\t$word\t0\t0\t0\n";
		}

		++$wordentry->[$useindex];

		print $fh_tablewords "$wordentry->[0]\t$lastid\n";
	    }

	    ++$i;
	    return if $i % 100;

	    printf "%s : %12d  %3d%%\r",
	    	scalar(localtime),
		$i, 100*$i/($rows||1),
		if -t;
	};

	while (my $row = $sql->NextRowRef)
	{
	    my $id = $row->[0];

	    if ($id != $lastid)
	    {
		$flush->() if @tokens;
		$lastid = $id;
		@tokens = ();
	    }

	    push @tokens, map { scalar $self->Tokenize($_) }
		grep { defined }
		@$row[1..$#$row];
	}

	$flush->() if @tokens;
	$sql->Finish;

	print localtime() . " : Query completed, $i rows.\n";
    };

    $sub->(
	"SELECT id, name FROM artist
	UNION
	SELECT ref, name FROM artistalias
	ORDER BY 1",
	"artist",
	$fh_artistwords,
	1,
    );

    $sub->("SELECT id, name FROM album", "album", $fh_albumwords, 2);
    $sub->("SELECT id, name FROM track", "track", $fh_trackwords, 3);

    while (my ($word, $e) = each %words)
    {
	# Don't overflow the 'smallint' columns
	$e->[1] = 32767 if $e->[1] > 32767;
	$e->[2] = 32767 if $e->[2] > 32767;
	$e->[3] = 32767 if $e->[3] > 32767;

	print $fh_wordlist "$e->[0]\t$word\t$e->[1]\t$e->[2]\t$e->[3]\n";
    }

    my $drop = sub {
	$sql->AutoCommit;
	eval { $sql->Do(@_); 1 } or warn $@;
    };

    $drop->("ALTER TABLE wordlist DROP CONSTRAINT wordlist_pkey");
    $drop->("ALTER TABLE wordlist DROP CONSTRAINT wordlist_word_key");

    for my $table (qw( artist album track ))
    {
	$drop->("DROP INDEX ${table}words_${table}wordindex");
	$drop->("DROP INDEX ${table}words_${table}idindex");
    }

    my $load = sub {
	my ($fh, $table) = @_;

	seek($fh, 0, 0) or die;
	my $size = -s $fh;

	print localtime() . " : Loading into table $table\n";

	$sql->AutoCommit;
	$sql->Do("TRUNCATE TABLE $table");
	$sql->AutoCommit;
	$sql->Do("COPY $table FROM stdin");

	my $i = 0;

	while (<$fh>)
	{
	    $dbh->func($_, "putline")
		or die "putline '$_' failed";
	    ++$i;
	    next if $i % 100;
	    printf "%s : %12d  %3d%%\r",
	    	scalar(localtime),
		$i, 100*tell($fh)/($size||1),
		if -t;
	}

	$dbh->func("\\.\n", "putline") or die;
	$dbh->func("endcopy") or die;

	print localtime() . " : loaded $i rows.\n";

	print localtime() . " : vacuuming...\n";
	$sql->AutoCommit;
	$sql->Do("VACUUM ANALYZE $table");

	print localtime() . " : done!\n";
    };

    $load->($fh_wordlist, "wordlist");
    $load->($fh_artistwords, "artistwords");
    $load->($fh_albumwords, "albumwords");
    $load->($fh_trackwords, "trackwords");

    $sql->Begin;
    $sql->Do("ALTER TABLE wordlist ADD PRIMARY KEY (id)");
    $sql->Do("ALTER TABLE wordlist ADD UNIQUE (word)");

    for my $table (qw( artist album track ))
    {
	$sql->Do("CREATE UNIQUE INDEX ${table}words_${table}wordindex ON
	    ${table}words (wordid, ${table}id)");
	$sql->Do("CREATE INDEX ${table}words_${table}idindex ON
	    ${table}words (${table}id)");
    }

    $sql->SelectSingleValue(
	"SELECT SETVAL('wordlist_id_seq', ?)",
	++$nextwordid,
    );

    $sql->Commit;
}

1;

# eof SearchEngine.pm
