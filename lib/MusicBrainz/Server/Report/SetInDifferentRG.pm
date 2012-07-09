package MusicBrainz::Server::Report::SetInDifferentRG;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Report::ReleaseGroupReport';

sub gather_data {
    my ($self, $writer) = @_;

    $self->gather_data_from_query(
        $writer,'
        SELECT DISTINCT
			rg.id AS release_group_id,
            rg_name.name AS release_group_name,
            rg.edits_pending AS release_group_edits_pending,
            rg.artist_credit AS artist_credit_id,
            rg.gid AS release_group_gid,
            musicbrainz_collate(rg_name.name) AS rg_name_collate,
            rg.comment AS release_group_comment
		FROM release_group rg
            JOIN release_name rg_name ON rg_name.id = rg.name
		    JOIN release rel ON rel.release_group = rg.id
		WHERE rel.id IN (
			SELECT r0.id
			FROM l_release_release l
				JOIN release r0 ON l.entity0 = r0.id
				JOIN release r1 ON l.entity1 = r1.id
                JOIN link ON l.link = link.id
                JOIN link_type ON link.link_type = link_type.id
			WHERE link_type.gid in (?, ?)
				AND r0.release_group <> r1.release_group
            UNION
			SELECT r1.id
			FROM l_release_release l
				JOIN release r0 ON l.entity0 = r0.id
				JOIN release r1 ON l.entity1 = r1.id
                JOIN link ON l.link = link.id
                JOIN link_type ON link.link_type = link_type.id
			WHERE link_type.gid in (?, ?)
				AND r0.release_group <> r1.release_group
		)
		ORDER BY musicbrainz_collate(rg_name.name)',
        ['6d08ec1e-a292-4dac-90f3-c398a39defd5', 'fc399d47-23a7-4c28-bfcf-0607a562b644',
         '6d08ec1e-a292-4dac-90f3-c398a39defd5', 'fc399d47-23a7-4c28-bfcf-0607a562b644']);
}

sub template { 'report/set_in_different_rg.tt' }

1;
