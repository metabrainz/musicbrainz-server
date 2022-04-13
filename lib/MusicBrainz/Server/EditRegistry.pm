package MusicBrainz::Server::EditRegistry;

use Class::Load qw( load_class );

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
    MusicBrainz::Server::Edit::Area::AddAlias
    MusicBrainz::Server::Edit::Area::AddAnnotation
    MusicBrainz::Server::Edit::Area::Create
    MusicBrainz::Server::Edit::Area::Delete
    MusicBrainz::Server::Edit::Area::DeleteAlias
    MusicBrainz::Server::Edit::Area::Edit
    MusicBrainz::Server::Edit::Area::EditAlias
    MusicBrainz::Server::Edit::Area::Merge
    MusicBrainz::Server::Edit::Event::AddAlias
    MusicBrainz::Server::Edit::Event::DeleteAlias
    MusicBrainz::Server::Edit::Event::AddAnnotation
    MusicBrainz::Server::Edit::Event::Create
    MusicBrainz::Server::Edit::Event::Delete
    MusicBrainz::Server::Edit::Event::Edit
    MusicBrainz::Server::Edit::Event::EditAlias
    MusicBrainz::Server::Edit::Event::Merge
    MusicBrainz::Server::Edit::Genre::Create
    MusicBrainz::Server::Edit::Genre::Delete
    MusicBrainz::Server::Edit::Instrument::AddAlias
    MusicBrainz::Server::Edit::Instrument::DeleteAlias
    MusicBrainz::Server::Edit::Instrument::AddAnnotation
    MusicBrainz::Server::Edit::Instrument::Create
    MusicBrainz::Server::Edit::Instrument::Delete
    MusicBrainz::Server::Edit::Instrument::Edit
    MusicBrainz::Server::Edit::Instrument::EditAlias
    MusicBrainz::Server::Edit::Instrument::Merge
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
    MusicBrainz::Server::Edit::Place::AddAlias
    MusicBrainz::Server::Edit::Place::DeleteAlias
    MusicBrainz::Server::Edit::Place::AddAnnotation
    MusicBrainz::Server::Edit::Place::Create
    MusicBrainz::Server::Edit::Place::Delete
    MusicBrainz::Server::Edit::Place::Edit
    MusicBrainz::Server::Edit::Place::EditAlias
    MusicBrainz::Server::Edit::Place::Merge
    MusicBrainz::Server::Edit::Recording::AddAnnotation
    MusicBrainz::Server::Edit::Recording::AddAlias
    MusicBrainz::Server::Edit::Recording::DeleteAlias
    MusicBrainz::Server::Edit::Recording::EditAlias
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
    MusicBrainz::Server::Edit::Relationship::Reorder
    MusicBrainz::Server::Edit::Release::AddAnnotation
    MusicBrainz::Server::Edit::Release::AddCoverArt
    MusicBrainz::Server::Edit::Release::AddAlias
    MusicBrainz::Server::Edit::Release::DeleteAlias
    MusicBrainz::Server::Edit::Release::EditAlias
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
    MusicBrainz::Server::Edit::Release::RemoveCoverArt
    MusicBrainz::Server::Edit::Release::ReorderCoverArt
    MusicBrainz::Server::Edit::Release::ReorderMediums
    MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation
    MusicBrainz::Server::Edit::ReleaseGroup::AddAlias
    MusicBrainz::Server::Edit::ReleaseGroup::DeleteAlias
    MusicBrainz::Server::Edit::ReleaseGroup::EditAlias
    MusicBrainz::Server::Edit::ReleaseGroup::Create
    MusicBrainz::Server::Edit::ReleaseGroup::Delete
    MusicBrainz::Server::Edit::ReleaseGroup::Edit
    MusicBrainz::Server::Edit::ReleaseGroup::Merge
    MusicBrainz::Server::Edit::ReleaseGroup::SetCoverArt
    MusicBrainz::Server::Edit::Series::AddAlias
    MusicBrainz::Server::Edit::Series::DeleteAlias
    MusicBrainz::Server::Edit::Series::AddAnnotation
    MusicBrainz::Server::Edit::Series::Create
    MusicBrainz::Server::Edit::Series::Delete
    MusicBrainz::Server::Edit::Series::Edit
    MusicBrainz::Server::Edit::Series::EditAlias
    MusicBrainz::Server::Edit::Series::Merge
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
    MusicBrainz::Server::Edit::Historic::MoveReleaseToRG
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
        load_class($class) or die $@;
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
