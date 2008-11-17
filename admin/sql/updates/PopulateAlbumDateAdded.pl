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

use strict;

use FindBin;
use lib "$FindBin::Bin/../../../cgi-bin";

use DBDefs;
use MusicBrainz;
use Sql;

my $mb = MusicBrainz->new;
$mb->Login();
my $sql = Sql->new($mb->{DBH});

$sql->Begin;
$sql->Do("create temporary table tmp_album_opentime as SELECT rowid as id, min(opentime) as opentime FROM moderation_all WHERE type = 16 and rowid > 0 group by rowid");
$sql->Do("alter table tmp_album_opentime add constraint tmp_album_opentime_pk primary key (id)");
$sql->Do("update albummeta set dateadded = t.opentime from tmp_album_opentime t where t.id=albummeta.id");
$sql->Commit;

# eof
