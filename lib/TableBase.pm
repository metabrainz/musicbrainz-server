package TableBase;
use Moose;
use MooseX::Storage;
with Storage;

use DBDefs;
use Encode qw( decode );
use LocaleSaver;
use MusicBrainz::Server::Validation qw( unaccent );
use POSIX qw(:locale_h);
use Sql;
use Text::Unaccent;

use constant MAX_PAGE_INDEX_LEVELS => 6;
use constant NUM_BITS_PAGE_INDEX => 5;

use constant TABLE_RELEASE => 1;
use constant TABLE_ARTIST => 2;
use constant TABLE_TRACK => 3;
use constant TABLE_LABEL => 4;

=head1 NAME

TableBase - base for all MusicBrainz entities

=head1 SYNOPSIS

	package MyEntity;
	use Moose;
	extends 'TableBase';
	
	has '

=head1 DESCRIPTION

This class serves as a base class for all of the main MusicBrainz entities

=head1 SLOTS

=head2 entity_type

A string representation of this type of entity, commonly used to get the assossciated table back.

=cut

has 'entity_type' => (
	is => 'rw'
);

=head2 dbh

The database handle that this object was initialized with.

=cut

has 'dbh' => (
	is => 'rw',
	traits => [ 'DoNotSerialize' ],
);

=head2 id

The row id of this entity

=cut

has 'id' => (
	is => 'rw'
);

=head2 mbid

A unique global-identifier assossciated with this entity.

=cut

has 'mbid' => (
	is       => 'rw',
	init_arg => 'gid',
);

=head2 name

The name of this entity

=cut

has 'name' => (
	is => 'rw'
);

=head2 has_mod_pending

Boolean, whether this entity has edits pending in the edit queue

=cut

has 'has_mod_pending' => (
    is       => 'rw',
    init_arg => 'modpending',
);

sub BUILDARGS
{
	my ($self, $dbh, @rest) = @_;
	
	my $hash = scalar @rest == 1 && ref $rest[0] eq 'HASH' ? $rest[0] : { @rest };
	$hash->{dbh} = $dbh;
	
	return $hash;
}

# Hack so _new_from_row works
sub BUILD
{
	my ($self, $args) = @_;

	my %arguments = %$args;
 	my @extra = grep { !exists $self->{$_} } keys %arguments;
 	@{$self}{@extra} = @arguments{@extra};

	return $self;
}

sub _new_from_row
{
	my ($self, $row, %opts) = @_;
	return unless $row;

    if (exists $opts{strip_prefix})
    {
        my $prefix = $opts{strip_prefix};
        $row = {
            map {
                my ($pre, $key) = ($_ =~ /^($prefix)(.*)$/);
                $key => $row->{$_};
            } grep { /^$prefix/ } keys %$row
        };
    }

    my $dbh = ref $self ? $self->dbh : undef;
	return $self->new($dbh, $row);
}

sub GetNewInsert
{
   return $_[0]->{new_insert};
}

sub CreateNewGlobalId
{
    my ($this) = @_;

    require OSSP::uuid;
    my $uuid = new OSSP::uuid;
    $uuid->make("v4");
    return $uuid->export("str");
}  

sub CheckGlobalIdRedirect
{
    my ($this, $gid, $tbl) = @_;
    
    my $sql = Sql->new($this->dbh);
    return $sql->SelectSingleValue("SELECT newid FROM gid_redirect WHERE gid = ? AND tbl = ?", $gid, $tbl) or undef;
}

sub SetGlobalIdRedirect
{
    my ($this, $id, $gid, $newid, $tbl) = @_;
    
    my $sql = Sql->new($this->dbh);
    # Update existing redirects
    $sql->Do("UPDATE gid_redirect SET newid = ? WHERE newid = ? AND tbl = ?", $newid, $id, $tbl);
    # Add a new redirect
    $sql->Do("INSERT INTO gid_redirect (gid, newid, tbl) VALUES (?, ?, ?)", $gid, $newid, $tbl);
}

sub RemoveGlobalIdRedirect
{
    my ($this, $newid, $tbl) = @_;
    
    my $sql = Sql->new($this->dbh);
    # Remove existing redirects
    $sql->Do("DELETE FROM gid_redirect WHERE newid = ? AND tbl = ?", $newid, $tbl);
}

sub CalculatePageIndex 
{
    my ($this, $string) = @_;
    my ($path, $ch, $base, @chars, $o, $wild);

    @chars = do
    {
	use locale;
	my $saver = new LocaleSaver(LC_CTYPE, "en_US.UTF-8");

	$string = unaccent($string);
	$string = decode("utf-8", $string);
	$string =~ tr/A-Za-z /_/c;

	split //, uc($string);
    };

    $path = 0;
    $base = ord('A');

    my $endpath = 0;
    my $allbitsset = ((1 << NUM_BITS_PAGE_INDEX) - 1);

    for(0..MAX_PAGE_INDEX_LEVELS-1)
    {
	my ($start_ch, $end_ch) = (0, $allbitsset);

	if (defined(my $ch = $chars[$_]))
	{
		$start_ch = $end_ch
			= ($ch eq '_') ? 0
			: ($ch eq ' ') ? 1
			: ord($ch) - $base + 2;
	}

        $path |= $start_ch << (NUM_BITS_PAGE_INDEX * (MAX_PAGE_INDEX_LEVELS - $_ - 1));
        $endpath |= $end_ch << (NUM_BITS_PAGE_INDEX * (MAX_PAGE_INDEX_LEVELS - $_ - 1));
    }

    return ($path, $endpath) if wantarray;
    return $path;
}

=head1 LICENSE

MusicBrainz -- the open internet music database

Copyright (C) 2000 Robert Kaye

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;
1;
