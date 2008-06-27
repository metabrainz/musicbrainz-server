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

package MusicBrainz::Server::Markup;

use strict;
use MusicBrainz::Server::Validation;

# TODO recognise URLs in the parse stage, not in the render stage
use constant TOKEN_SUMMARY_MARKER => chr(12);
use constant TOKEN_NEW_PARA => chr(10);

sub parse
{
	my ($class, $text) = @_;

	$text =~ s/(\015\012|\012\015|\012|\015)\1+/\n\n/g;
	MusicBrainz::Server::Validation::TrimInPlace($text);

	my @paras = split /\n\n+/, $text;

	my @out;
	for my $p (@paras)
	{
		push @out, TOKEN_NEW_PARA if @out;
		if ($class->is_marker_para($p))
		{
			push @out, TOKEN_SUMMARY_MARKER;
		} 
		else 
		{
			push @out, @{ $class->parse_para($p) };
		}
	}

	\@out;
}

sub is_marker_para
{
	$_[1] =~ /\A-+\z/;
}

sub parse_para
{
	my ($class, $para) = @_;
	$para =~ s/\s+/ /g;
	$para =~ s/\A //g;
	$para =~ s/ \z//g;
	# The spaces between words are included as part of the word tokens to make
	# the "diff" output more intuitive; for example if you diff "a big red
	# ball" to "a small green ball", the obvious diff is s/big red/small
	# green/.  If spaces were their own tokens, the diff would be s/big/small/
	# and s/red/green/.
	my @words = split /(?= )/, $para;
	\@words;
}

################################################################################
# De-parse
################################################################################

sub deparse
{
	my ($class, $parsed) = @_;
	local $_;

	my $markup = "";

	for (@$parsed)
	{
		$markup .= (
			$_ eq TOKEN_SUMMARY_MARKER ? "-"
			:
			$_ eq TOKEN_NEW_PARA ? "\n\n"
			:
			$_
		);
	}

	$markup;
}

sub normalise
{
	# TODO: We need to check to see if this needs to be normalized at all. 
	# Security issues abound, no doubt.
	my $class = shift;
    return shift;
    #my $text = $class->deparse($class->parse(@_));
    #$text;
}

################################################################################
# Show as HTML
################################################################################

sub as_html
{
	my ($class, $t) = @_;
	$t = $class->parse($t) unless ref($t);
	local $_;

	my $html = "";
	my $para = "";

	for (@$t)
	{
		next if $_ eq TOKEN_SUMMARY_MARKER;

		if ($_ eq TOKEN_NEW_PARA)
		{
			$html .= "<p>$para</p>" unless $para eq "";
			$para = "";
			next;
		}

		use MusicBrainz::Server::Validation qw( encode_entities );
		if (m"^( ?)((ftp|http|https)://.*)")
		{
			my $sp = $1;
			my $t = encode_entities($2);
			
			# shorten url's that are longer than freedb url's (~75 chars)
			# http://www.freedb.org/freedb_search_fmt.php?cat=misc&id=3a055005
			my $disp = (length($t) > 75
				? substr($t, 0, 72) . "..."
				: $t);
			
			$para .= qq!$sp<a href="$t" title="$t">$disp</a>!;
		} 
		else 
		{
			$para .= encode_entities($_);
		}
	}

	$html .= "<p>$para</p>" unless ($para eq "");

	$html;
}

################################################################################
# Diff two bits of markup as HTML
################################################################################

sub diff_as_html
{
	my ($class, $t1, $t2) = @_;
	my $p1 = $class->parse($t1);
	my $p2 = $class->parse($t2);

	use Algorithm::Diff qw( compact_diff );
	my @compact = compact_diff($p1, $p2);

	my $html = qq!<div class="markupdiff">!;

	my $eq = 1;
	while (@compact > 2)
	{
		my ($p1s, $p2s, $p1e, $p2e) = @compact[0..3];

		# Skip empty matching sequence, e.g. if the first items differ
		next if ($eq and $p1s == $p1e);

		if ($eq)
		{
			my @tokens = @$p1[$p1s .. $p1e-1];
			$html .= $class->print_chunk("diff-nochange", \@tokens);
		} 
		elsif ($p1s == $p1e) 
		{
			# Addition in seq2
			my @tokens = @$p2[$p2s .. $p2e-1];
			$html .= $class->print_chunk("diff-add", \@tokens);
		} 
		elsif ($p2s == $p2e) 
		{
			# Addition in seq1 (removed in seq2)
			my @tokens = @$p1[$p1s .. $p1e-1];
			$html .= $class->print_chunk("diff-del", \@tokens);
		} 
		else 
		{
			# Changed items
			my @tokens1 = @$p1[$p1s .. $p1e-1];
			my @tokens2 = @$p2[$p2s .. $p2e-1];
			$html .= $class->print_chunk("diff-changedel", \@tokens1);
			$html .= $class->print_chunk("diff-changeadd", \@tokens2);
		}
	} 
	continue 
	{
		$eq = not $eq;
		splice(@compact, 0, 2);
	}

	$html .= qq!</div>!;

	$html;
}

sub print_chunk
{
	my ($class, $type, $tokens) = @_;
	qq!<span class="$type">! . $class->output_tokens($tokens) . qq!</span>!;
}

sub output_tokens
{
	my ($class, $tokens) = @_;
	local $_;

	my $html = "";

	for (@$tokens)
	{
		$html .= (
			$_ eq TOKEN_SUMMARY_MARKER 
				? "----"
				: $_ eq TOKEN_NEW_PARA 
					? "&#xB6;<br /><br />"
					: MusicBrainz::Server::Validation::encode_entities($_)
		);
	}

	$html;
}

1;
# eof Markup.pm
