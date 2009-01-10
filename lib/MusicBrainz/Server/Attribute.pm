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
use MusicBrainz::Server::LinkAttr;

package MusicBrainz::Server::Attribute;

use Carp qw( croak );
use base qw( TableBase );
require MusicBrainz::Server::Artist;
require MusicBrainz::Server::Release;
require MusicBrainz::Server::Track;

################################################################################
# Bare Constructor
################################################################################

sub new
{
    my ($class, $dbh, $types, $link) = @_;

    my $self = $class->SUPER::new($dbh);

	# So far, links are always between two things.  This may change one day.
    # if anything else other than two types are passed in, this object will
    # be an on-the-fly object (read: const object)
	if (defined $types && @$types == 2)
	{
		ref($types) eq "ARRAY" or return undef;

		MusicBrainz::Server::LinkEntity->ValidateTypes($types)
			or return undef;
		my @t = @$types;
		$self->{'type'} = join "_", @t;
		$self->{'table'} = "link_attribute";
		$self->{'reftable'} = "l_" . join "_", @t;
		$self->{'link'} = $link;
		$self->{'attributes'} = [];
    }

    $self;
}

################################################################################
# Properties
################################################################################

sub Table		  	 { $_[0]{table} }
# Get/id implemented by TableBase
sub GetNumAttributes { scalar(@{$_[0]{attributes}}) }
sub GetAttributeType { $_[0]{attribute_type} }

################################################################################
# Data Retrieval
################################################################################

sub _new_from_attribute_ids
{
	my ($this, $linkid, $attrs) = @_;

	my $self = {};
	while (my ($k, $v) = each %$this)
	{
		$self->{$k} = $v;
	}
	$self->{'link'} = $linkid;
	$self->{'attributes'} = $attrs;
	$self->{'DBH'} = $this->dbh;

	bless $self, ref($this) || $this;
}

sub newFromLinkId
{
	my ($self, $linkid) = @_;
	my $sql = Sql->new($self->dbh);
	my $attrs = $sql->SelectSingleColumnArray(
		"SELECT attribute_type FROM $self->{table} WHERE link = ? AND link_type = ?",
		$linkid, $self->{type}
	);
	$self->_new_from_attribute_ids($linkid, $attrs);
}

sub attributes
{
    my ($self, $new_attrs) = @_;
    
    if (defined $new_attrs) { $self->{attributes} = $new_attrs; }

    my @attributes;
    my $link_attr = MusicBrainz::Server::LinkAttr->new($self->dbh);
    
    foreach my $attr (@{ $self->{attributes} })
    {
        my $obj = $link_attr->newFromId($attr);
        if ($obj)
        {
            my @p = $obj->PathFromRoot();
            if (scalar(@p) > 1)
            {
                push @attributes, { 
                    name       => $p[1]->name(), 
                    valuei     => $attr,
                    value_text => $obj->name(),
                };
            }
        }
    }

    return \@attributes;
}

sub ReplaceAttributes
{
	my ($self, $phrase, $rphrase) = @_;

    my $linkattr = MusicBrainz::Server::LinkAttr->new($self->dbh);
	my %temp;
	foreach my $attr (@{$self->{attributes}})
	{
		my $obj = $linkattr->newFromId($attr);
        if ($obj)
		{
			my @p = $obj->PathFromRoot();
			if (scalar(@p) > 1)
			{
		        push @{$temp{$p[1]->name()}}, $obj->name();
			}
		}
	}

	$phrase = _replace_attributes($phrase, \%temp);
	$rphrase = _replace_attributes($rphrase, \%temp);
	return ($phrase, $rphrase);
}

sub _join_words
{
	my ($words) = @_;
	my @words = @$words;
	my $numwords = scalar(@words);
	my ($last, $result);

	if ($numwords == 1) {
		return $words[0];
	}
	elsif ($numwords == 2) {
		$result = $words[0];
		$last = $words[1];
	}
	else {
		$last = pop(@words);
		$result = join(", ", @words);
	}
	return $result . " and " . $last;
}

sub _replace_attributes
{
	my ($phrase, $attrs) = @_;

	my @result;
	my @tokens = split(/({.*?}\s*)/, $phrase);
	my $is_tag = 0;

	foreach my $token (@tokens) {

		if ($is_tag) {

			$token =~ /{(.*?)(?::(.*?))?(?:\|(.*?))?}(\s*)/;
			my $name = $1;
			my $alternative_replacement = $2;
			my $unset_replacement = $3;
			my $space = $4;

			my $replacement = $attrs->{"__$name"};
			if (!defined($replacement)) {
				my @values;
				for my $n (split(/\+/, $name)) {
					my $attr = $attrs->{$n};
					if (defined($attr) && @$attr) {
						push @values, @$attr;
					}
				}
				$replacement = @values ? lc(_join_words(\@values)) : "";
				$attrs->{"__$name"} = $replacement;
			}

			if ($replacement) {
				$token = $replacement;
				if ($alternative_replacement) {
 					$alternative_replacement =~ s/%/$token/;
					$token = $alternative_replacement;
				}
			}
			else {
				$token = $unset_replacement;
			}

			$token .= $space if $token;
		}

		push(@result, $token) if $token;
		$is_tag = !$is_tag;
	}

	return join("", @result);
}

sub Exists
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);

	my $row = $sql->SelectSingleValue(
			"SELECT count(*) FROM $self->{table} WHERE link = ? AND link_type = ?",
		    $self->{'link'}, $self->{'type'}
			);
	return $row > 0;
}

sub Insert
{
	my ($self, $attrs) = @_;

	$self->{attributes} = $attrs;
    return undef
	    if ($self->Exists);

	my $sql = Sql->new($self->dbh);
	foreach my $attr (@$attrs)
	{
		$sql->Do(
			"INSERT INTO $self->{table} (attribute_type, link, link_type) values (?, ?, ?)",
		    $attr, $self->{'link'}, $self->{'type'}
		);
    }
	$self;
}

sub Update
{
	my ($self, $attrs) = @_;

	$self->Delete();
	return $self->Insert($attrs);
}

sub Delete
{
	my $self = shift;

	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"DELETE FROM $self->{table} where link = ? and link_type = ?",
        $self->{'link'}, $self->{'type'}
	) or return undef;

	return 1;
}

################################################################################
# Merging
################################################################################

sub MergeLinks
{
	my ($self, $oldid, $newid) = @_;
	
	my $sql = Sql->new($self->dbh);
	my $rows = $sql->SelectListOfHashes(
		"SELECT * FROM $self->{table} WHERE link = ? AND link_type = ?",
		$oldid, $self->{type});
	
	my @delete;
	
	foreach my $row (@$rows)
	{
		my $count = $sql->SelectSingleValue(
			"SELECT COUNT(*) FROM $self->{table} WHERE link = ? AND ".
			"link_type = ? AND attribute_type = ?",
			$newid, $self->{type}, $row->{attribute_type});
		
		if ($count == 0)
		{
			# Move attribute
			$sql->Do("UPDATE $self->{table} SET link = ? WHERE id = ?", 
					 $newid, $row->{id});
		}
		else
		{
			# Delete attribute
			push @delete, $row->{id};
		}
	}
	
	# Delete unused attributes
	$sql->Do("DELETE FROM $self->{table} WHERE id IN (" . (join ", ", @delete) . ")")
		if @delete;
}

1;
# eof Attribute.pm
