echo "This script will take hours to run. Make sure you're running me in screen :)"

echo "SET search_path = musicbrainz; UPDATE musicbrainz.artist SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.artist
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.artist_alias SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.artist_alias
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_artist_artist SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_artist_artist
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_artist_label SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_artist_label
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_artist_recording SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_artist_recording
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_artist_release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_artist_release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_artist_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_artist_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_artist_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_artist_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_artist_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_artist_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_label_label SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_label_label
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_label_recording SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_label_recording
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_label_release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_label_release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_label_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_label_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_label_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_label_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_label_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_label_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_recording_recording SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_recording_recording
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_recording_release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_recording_release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_recording_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_recording_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_recording_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_recording_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_recording_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_recording_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_release_release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_release_release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_release_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_release_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_release_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_release_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_release_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_release_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_release_group_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_release_group_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_release_group_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_release_group_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_release_group_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_release_group_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_url_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_url_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_url_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_url_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.l_work_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.l_work_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.label SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.label
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.label_alias SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.label_alias
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.medium SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.medium
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.medium_cdtoc SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.medium_cdtoc
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.recording SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.recording
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.track SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.track
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

echo "SET search_path = musicbrainz; UPDATE musicbrainz.work_alias SET edits_pending = 0
WHERE id IN (
  SELECT id FROM musicbrainz.work_alias
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60]

