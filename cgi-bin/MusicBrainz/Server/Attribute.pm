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
require Artist;
require Album;
require Track;

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
# Get/SetId implemented by TableBase
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
	$self->{DBH} = $this->{DBH};

	bless $self, ref($this) || $this;
}

sub newFromLinkId
{
	my ($self, $linkid) = @_;
	my $sql = Sql->new($self->{DBH});
	my $attrs = $sql->SelectSingleColumnArray(
		"SELECT attribute_type FROM $self->{table} WHERE link = ? AND link_type = ?",
		$linkid, $self->{type}
	);
	$self->_new_from_attribute_ids($linkid, $attrs);
}

sub SetAttributes
{
	my ($self, $attrs) = @_;
	$self->{attributes} = $attrs;
}

sub GetAttributes
{
	my ($self) = @_;
	my @attrs;

    my $linkattr = MusicBrainz::Server::LinkAttr->new($self->{DBH});
	foreach my $attr (@{$self->{attributes}})
	{
		my $obj = $linkattr->newFromId($attr);
        if ($obj)
		{
			my @p = $obj->PathFromRoot();
			if (scalar(@p) > 1)
			{
				push @attrs, { 
					           name=>$p[1]->GetName(), 
					           value=>$attr,
							   value_text=>$obj->GetName(),
				             };
			}
		}
	}

    return \@attrs;
}

sub ReplaceAttributes
{
	my ($self, $phrase, $rphrase) = @_;

    my $linkattr = MusicBrainz::Server::LinkAttr->new($self->{DBH});
	my %temp;
	foreach my $attr (@{$self->{attributes}})
	{
		my $obj = $linkattr->newFromId($attr);
        if ($obj)
		{
			my @p = $obj->PathFromRoot();
			if (scalar(@p) > 1)
			{
		        push @{$temp{$p[1]->GetName()}}, $obj->GetName();
			}
		}
	}

	foreach my $attr (keys %temp)
	{
		my $rep_name;

		if (scalar(@{$temp{$attr}}) == 1)
		{
    		$rep_name = shift @{$temp{$attr}};
		}
		elsif (scalar(@{$temp{$attr}}) == 2)
		{
    		$rep_name = shift @{$temp{$attr}};
    		$rep_name .= " and " . shift @{$temp{$attr}};
		}
		else
		{
    		my $last = pop @{$temp{$attr}};
    		$rep_name = join ", ", @{$temp{$attr}};
    		$rep_name .= " and " . $last;
		}
		$rep_name =~ s/\s*?(.*?)\s*/$1/;
		$rep_name =~ tr/A-Z/a-z/;
	   
		if ($phrase =~ /\{$attr\}/)
		{
			$phrase =~ s/\{$attr\}/$rep_name/;
			$rphrase =~ s/\{$attr\}/$rep_name/;
		}
		elsif ($phrase =~ /\{$attr:(.*?)\}/)
		{
			my $saved = $1;
			$phrase =~ s/\{$attr:.*?\}/$saved/;
			$rphrase =~ s/\{$attr:.*?\}/$saved/;
		}
	}

    $phrase =~ s/\{.*?\}\s*?//g;
    $rphrase =~ s/\{.*?\}\s*?//g;

	return ($phrase, $rphrase);
}

sub Exists
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

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

	my $sql = Sql->new($self->{DBH});
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

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"DELETE FROM $self->{table} where link = ? and link_type = ?",
        $self->{'link'}, $self->{'type'}
	) or return undef;

	return 1;
}

1;
# eof Attribute.pm
