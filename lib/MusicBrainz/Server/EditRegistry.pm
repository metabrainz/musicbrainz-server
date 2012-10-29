package MusicBrainz::Server::EditRegistry;

use Class::MOP;

our %_types;
our $_registered = 0;

my @CLASSES = qw(
    MusicBrainz::Server::Edit::Artist::AddAlias
    MusicBrainz::Server::Edit::Artist::AddAnnotation
    MusicBrainz::Server::Edit::Artist::Create
    MusicBrainz::Server::Edit::Artist::DeleteAlias
    MusicBrainz::Server::Edit::Artist::Delete
    MusicBrainz::Server::Edit::Artist::Edit
    MusicBrainz::Server::Edit::Artist::EditAlias
    MusicBrainz::Server::Edit::Artist::Merge
    MusicBrainz::Server::Edit::Artist::EditArtistCredit
    MusicBrainz::Server::Edit::Label::AddAlias
    MusicBrainz::Server::Edit::Label::DeleteAlias
    MusicBrainz::Server::Edit::Label::AddAnnotation
    MusicBrainz::Server::Edit::Label::Create
    MusicBrainz::Server::Edit::Label::Delete
    MusicBrainz::Server::Edit::Label::Edit
    MusicBrainz::Server::Edit::Label::EditAlias
    MusicBrainz::Server::Edit::Label::Merge
    MusicBrainz::Server::Edit::Medium::AddDiscID
    MusicBrainz::Server::Edit::Medium::Create
    MusicBrainz::Server::Edit::Medium::Delete
    MusicBrainz::Server::Edit::Medium::Edit
    MusicBrainz::Server::Edit::Medium::MoveDiscID
    MusicBrainz::Server::Edit::Medium::RemoveDiscID
    MusicBrainz::Server::Edit::Medium::SetTrackLengths
    MusicBrainz::Server::Edit::PUID::Delete
    MusicBrainz::Server::Edit::Recording::AddAnnotation
    MusicBrainz::Server::Edit::Recording::AddPUIDs
    MusicBrainz::Server::Edit::Recording::Create
    MusicBrainz::Server::Edit::Recording::Delete
    MusicBrainz::Server::Edit::Recording::Edit
    MusicBrainz::Server::Edit::Recording::RemoveISRC
    MusicBrainz::Server::Edit::Recording::AddISRCs
    MusicBrainz::Server::Edit::Recording::Merge
    MusicBrainz::Server::Edit::Relationship::AddLinkAttribute
    MusicBrainz::Server::Edit::Relationship::AddLinkType
    MusicBrainz::Server::Edit::Relationship::Create
    MusicBrainz::Server::Edit::Relationship::Delete
    MusicBrainz::Server::Edit::Relationship::Edit
    MusicBrainz::Server::Edit::Relationship::EditLinkAttribute
    MusicBrainz::Server::Edit::Relationship::EditLinkType
    MusicBrainz::Server::Edit::Relationship::RemoveLinkAttribute
    MusicBrainz::Server::Edit::Relationship::RemoveLinkType
    MusicBrainz::Server::Edit::Release::AddAnnotation
    MusicBrainz::Server::Edit::Release::AddCoverArt
    MusicBrainz::Server::Edit::Release::AddReleaseLabel
    MusicBrainz::Server::Edit::Release::ChangeQuality
    MusicBrainz::Server::Edit::Release::Create
    MusicBrainz::Server::Edit::Release::Delete
    MusicBrainz::Server::Edit::Release::DeleteReleaseLabel
    MusicBrainz::Server::Edit::Release::Edit
    MusicBrainz::Server::Edit::Release::EditArtist
    MusicBrainz::Server::Edit::Release::EditBarcodes
    MusicBrainz::Server::Edit::Release::EditCoverArt
    MusicBrainz::Server::Edit::Release::EditReleaseLabel
    MusicBrainz::Server::Edit::Release::Merge
    MusicBrainz::Server::Edit::Release::Move
    MusicBrainz::Server::Edit::Release::RemoveCoverArt
    MusicBrainz::Server::Edit::Release::ReorderCoverArt
    MusicBrainz::Server::Edit::Release::ReorderMediums
    MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation
    MusicBrainz::Server::Edit::ReleaseGroup::Create
    MusicBrainz::Server::Edit::ReleaseGroup::Delete
    MusicBrainz::Server::Edit::ReleaseGroup::Edit
    MusicBrainz::Server::Edit::ReleaseGroup::Merge
    MusicBrainz::Server::Edit::ReleaseGroup::SetCoverArt
    MusicBrainz::Server::Edit::URL::Edit
    MusicBrainz::Server::Edit::WikiDoc::Change
    MusicBrainz::Server::Edit::Work::AddAlias
    MusicBrainz::Server::Edit::Work::AddAnnotation
    MusicBrainz::Server::Edit::Work::AddISWCs
    MusicBrainz::Server::Edit::Work::Create
    MusicBrainz::Server::Edit::Work::Delete
    MusicBrainz::Server::Edit::Work::DeleteAlias
    MusicBrainz::Server::Edit::Work::Edit
    MusicBrainz::Server::Edit::Work::EditAlias
    MusicBrainz::Server::Edit::Work::Merge
    MusicBrainz::Server::Edit::Work::RemoveISWC

    MusicBrainz::Server::Edit::Historic::AddDiscID
    MusicBrainz::Server::Edit::Historic::AddLink
    MusicBrainz::Server::Edit::Historic::AddRelease
    MusicBrainz::Server::Edit::Historic::AddReleaseAnnotation
    MusicBrainz::Server::Edit::Historic::AddReleaseEvents
    MusicBrainz::Server::Edit::Historic::AddTrack
    MusicBrainz::Server::Edit::Historic::AddTrackKV
    MusicBrainz::Server::Edit::Historic::ChangeArtistQuality
    MusicBrainz::Server::Edit::Historic::ChangeReleaseGroup
    MusicBrainz::Server::Edit::Historic::ChangeReleaseQuality
    MusicBrainz::Server::Edit::Historic::ChangeTrackArtist
    MusicBrainz::Server::Edit::Historic::EditLink
    MusicBrainz::Server::Edit::Historic::EditReleaseAttrs
    MusicBrainz::Server::Edit::Historic::EditReleaseEvents
    MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld
    MusicBrainz::Server::Edit::Historic::EditReleaseLanguage
    MusicBrainz::Server::Edit::Historic::EditReleaseName
    MusicBrainz::Server::Edit::Historic::EditTrackLength
    MusicBrainz::Server::Edit::Historic::EditTrackName
    MusicBrainz::Server::Edit::Historic::EditTrackNum
    MusicBrainz::Server::Edit::Historic::MACToSAC
    MusicBrainz::Server::Edit::Historic::MergeRelease
    MusicBrainz::Server::Edit::Historic::MergeReleaseMAC
    MusicBrainz::Server::Edit::Historic::MoveDiscID
    MusicBrainz::Server::Edit::Historic::MoveRelease
    MusicBrainz::Server::Edit::Historic::RemoveDiscID
    MusicBrainz::Server::Edit::Historic::RemoveLabelAlias
    MusicBrainz::Server::Edit::Historic::RemoveLink
    MusicBrainz::Server::Edit::Historic::RemoveRelease
    MusicBrainz::Server::Edit::Historic::RemoveReleaseEvents
    MusicBrainz::Server::Edit::Historic::RemoveReleases
    MusicBrainz::Server::Edit::Historic::RemoveTrack
    MusicBrainz::Server::Edit::Historic::SACToMAC
    MusicBrainz::Server::Edit::Historic::SetTrackLengthsFromCDTOC
);

sub register_type
{
    my ($class, $edit_class, $overwrite) = @_;
    _register_default_types() unless $_registered;
    $class->_register_type($edit_class, $overwrite);
}

sub class_from_type
{
    my ($class, $type) = @_;
    _register_default_types() unless $_registered;
    return $_types{$type};
}

sub get_all_types
{
    _register_default_types() unless $_registered;
    return keys %_types;
}

sub get_all_classes
{
    _register_default_types() unless $_registered;
    return values %_types;
}

sub _register_type
{
    my ($class, $edit_class, $overwrite) = @_;
    my $type = $edit_class->edit_type;
    warn "Type $type already registered" if exists $_types{$type} && !$overwrite;
    $_types{$type} = $edit_class;
}

sub _register_default_types
{
    foreach my $class (@CLASSES) {
        Class::MOP::load_class($class) or die $@;
        _register_type(undef, $class);
    }
    $_registered = 1;
}

sub grouped_by_name
{
    my $class = shift;
    my %grouped;
    foreach my $class ($class->get_all_classes) {
        my $name = $class->l_edit_name;
        $grouped{ $name } ||= [];
        push @{ $grouped{ $name } }, $class;
    }

    return %grouped;
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
