#!/usr/bin/perl -w

use strict;
use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use MusicBrainz::Server::Validation;
use Sql;

my $mb = MusicBrainz->new;
$mb->Login(db => "READWRITE");
my $sql = Sql->new($mb->dbh);

$sql->Begin;
eval {

print "Loading attribute types\n";
my %attr_id_map;
$sql->Select("SELECT * FROM public.link_attribute_type");
while (1) {
    my $row = $sql->NextRowHashRef or last;
    $attr_id_map{$row->{id}} = $row;
}
$sql->Finish;

$sql->Do("TRUNCATE link_attribute_type");
print "Inserting attribute types\n";
foreach my $attr (values %attr_id_map) {
    my $root = $attr;
    while ($root->{parent} > 0) {
        $root = $attr_id_map{$root->{parent}};
    }
    $sql->Do("
        INSERT INTO link_attribute_type
            (id, parent, root, childorder, gid, name, description)
            VALUES (?, ?, ?, ?, ?, ?, ?)",
        $attr->{id}, $attr->{parent}, $root->{id}, $attr->{childorder},
        $attr->{mbid}, $attr->{name}, $attr->{description});
}

my %attr_map;
$sql->Select("SELECT * FROM public.link_attribute_type WHERE parent=0");
while (1) {
    my $row = $sql->NextRowHashRef or last;
    $attr_map{$row->{name}} = $row->{id};
}
$sql->Finish;

my @entity_types = (
    ['album', 'album', 'release_group', 'release_group', 0],
    ['album', 'artist', 'artist', 'release_group', 1],
    ['album', 'label', 'label', 'release_group', 1],
    ['album', 'track', 'recording', 'release_group', 1],
    ['album', 'url', 'release_group', 'url', 0],
    ['artist', 'artist', 'artist', 'artist', 0],
    ['artist', 'label', 'artist', 'label', 0],
    ['artist', 'track', 'artist', 'recording', 0],
    ['artist', 'url', 'artist', 'url', 0],
    ['label', 'label', 'label', 'label', 0],
    ['label', 'track', 'label', 'recording', 0],
    ['label', 'url', 'label', 'url', 0],
    ['track', 'track', 'recording', 'recording', 0],
    ['track', 'url', 'recording', 'url', 0],
    ['url', 'url', 'url', 'url', 0],
);

$sql->Do("TRUNCATE link_type");
$sql->Do("TRUNCATE link_type_attribute_type");
my %link_type_map;
foreach my $t (@entity_types) {
    my ($orig_t0, $orig_t1, $new_t0, $new_t1, $reverse) = @$t;
    print "Converting $orig_t0 <=> $orig_t1 link types\n";
    my $rows = $sql->SelectListOfHashes("SELECT * FROM public.lt_${orig_t0}_${orig_t1}");
    foreach my $row (@$rows) {
        my $id = $sql->SelectSingleValue("SELECT nextval('link_type_id_seq')");
        my $key = join("_", $orig_t0, $orig_t1, $row->{id});
        $link_type_map{$key} = $id;
    }
    foreach my $row (@$rows) {
        my ($linkphrase, $rlinkphrase);
        if ($reverse) {
            $linkphrase = $row->{'rlinkphrase'};
            $rlinkphrase = $row->{'linkphrase'};
        }
        else {
            $linkphrase = $row->{'linkphrase'};
            $rlinkphrase = $row->{'rlinkphrase'};
        }
        my $key = join("_", $orig_t0, $orig_t1, $row->{id});
        my $id = $link_type_map{$key};
        my $parent_id = $row->{parent} || undef;
        if (defined($parent_id)) {
            $key = join("_", $orig_t0, $orig_t1, $parent_id);
            $parent_id = $link_type_map{$key} || undef;
        }
        $sql->Do("
            INSERT INTO link_type
                (id, parent, childorder, gid, name, description, linkphrase,
                 rlinkphrase, shortlinkphrase, priority, entitytype0,
                 entitytype1)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ", $id, $parent_id, $row->{childorder}, $row->{mbid},
        $row->{name}, $row->{description}, $linkphrase, $rlinkphrase,
        $row->{shortlinkphrase}, $row->{priority}, $new_t0, $new_t1);
        foreach my $attr (split / /, $row->{attribute}) {
            my ($name, $limits) = split /=/, $attr;
            my ($min_l, $max_l) = split /-/, $limits;
            $sql->Do("
                INSERT INTO link_type_attribute_type
                    (link_type, attribute_type, min, max)
                    VALUES (?, ?, ?, ?)
            ", $id, $attr_map{$name}, $min_l || undef, $max_l || undef);
        }
    }
}

print "Loading release group ID map\n";
my %rg_id_map;
$sql->Select("SELECT id, release_group FROM public.album");
while (1) {
    my $row = $sql->NextRowRef or last;
    $rg_id_map{$row->[0]} = $row->[1];
}
$sql->Finish;

    $sql->Do("TRUNCATE link");
    $sql->Do("TRUNCATE link_attribute");

foreach my $t (@entity_types) {
    my ($orig_t0, $orig_t1, $new_t0, $new_t1, $reverse) = @$t;
    my %links;
    my %l_links;
    my $n_links = 0;

    print "Converting $orig_t0 <=> $orig_t1 links\n";
    $sql->Do("TRUNCATE l_${new_t0}_${new_t1}");

    my %attribs;
    my $rows = $sql->SelectListOfHashes("SELECT * FROM public.link_attribute WHERE link_type='${orig_t0}_${orig_t1}'");
    foreach my $row (@$rows) {
        my $link = $row->{link};
        if (!exists($attribs{$link})) {
            $attribs{$link} = [];
        }
        push @{$attribs{$link}}, $row->{attribute_type};
    }

    $rows = $sql->SelectListOfHashes("SELECT * FROM public.l_${orig_t0}_${orig_t1}");
    my $i = 0;
    my $cnt = scalar(@$rows);
    foreach my $row (@$rows) {
        my $id = $row->{id};
        my @attrs;
        if (exists($attribs{$id})) {
            my %attrs = map { $_ => 1 } @{$attribs{$id}};
            @attrs = keys %attrs;
            @attrs = sort @attrs;
        }
        my $begindate = $row->{begindate} || "0000-00-00";
        my $enddate = $row->{enddate} || "0000-00-00";
        MusicBrainz::Server::Validation::TrimInPlace($begindate);
        MusicBrainz::Server::Validation::TrimInPlace($enddate);
        while (length($begindate) < 10) {
            $begindate .= "-00";
        }
        while (length($enddate) < 10) {
            $enddate .= "-00";
        }
        my $key = join("_", $row->{link_type}, $begindate, $enddate, @attrs);
        my $link_id;
        if (!exists($links{$key})) {
            $link_id = $sql->SelectSingleValue("SELECT nextval('link_id_seq')");
            $links{$key} = $link_id;
            my @begindate = split(/-/, $begindate);
            my @enddate = split(/-/, $enddate);
            my $link_type_key = join("_", $orig_t0, $orig_t1, $row->{link_type});
            $sql->Do("
                INSERT INTO link
                    (id, link_type, begindate_year, begindate_month, begindate_day,
                     enddate_year, enddate_month, enddate_day, attributecount)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ", $link_id, $link_type_map{$link_type_key},
                ($begindate[0] + 0) || undef,
                ($begindate[1] + 0) || undef,
                ($begindate[2] + 0) || undef,
                ($enddate[0] + 0) || undef,
                ($enddate[1] + 0) || undef,
                ($enddate[2] + 0) || undef,
                scalar(@attrs));
            foreach my $attr (@attrs) {
                $sql->Do("INSERT INTO link_attribute (link, attribute_type) VALUES (?, ?)",
                    $link_id, $attr);
            }
        }
        else {
            $link_id = $links{$key};
        }
        my ($entity0, $entity1);
        if ($reverse) {
            $entity0 = $row->{link1};
            $entity1 = $row->{link0};
        }
        else {
            $entity0 = $row->{link0};
            $entity1 = $row->{link1};
        }
        if ($new_t0 eq "release_group") {
            $entity0 = $rg_id_map{$entity0};
        }
        if ($new_t1 eq "release_group") {
            $entity1 = $rg_id_map{$entity1};
        }
        if ($i % 100 == 0) {
            printf STDERR " %d/%d\r", $i, $cnt;
        }
        $i += 1;
        $key = join("_", $link_id, $entity0, $entity1);
        if (!exists($l_links{$key})) {
            $l_links{$key} = 1;
            $sql->Do("INSERT INTO l_${new_t0}_${new_t1}
                (link, entity0, entity1) VALUES (?, ?, ?)",
                $link_id, $entity0, $entity1);
            $n_links++;
        }
    }

}

    $sql->Commit;
};
if ($@) {
    $sql->Rollback;
}
