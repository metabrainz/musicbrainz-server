echo "This script will take hours to run. Make sure you're running me in screen :)"

echo "UPDATE artist SET edits_pending = 0
WHERE id IN (
  SELECT id FROM artist
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE artist_alias SET edits_pending = 0
WHERE id IN (
  SELECT id FROM artist_alias
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_artist_artist SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_artist_artist
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_artist_label SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_artist_label
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_artist_recording SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_artist_recording
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_artist_release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_artist_release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_artist_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_artist_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_artist_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_artist_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_artist_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_artist_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_label_label SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_label_label
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_label_recording SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_label_recording
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_label_release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_label_release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_label_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_label_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_label_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_label_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_label_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_label_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_recording_recording SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_recording_recording
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_recording_release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_recording_release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_recording_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_recording_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_recording_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_recording_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_recording_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_recording_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_release_release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_release_release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_release_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_release_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_release_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_release_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_release_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_release_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_release_group_release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_release_group_release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_release_group_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_release_group_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_release_group_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_release_group_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_url_url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_url_url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_url_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_url_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE l_work_work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM l_work_work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE label SET edits_pending = 0
WHERE id IN (
  SELECT id FROM label
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE label_alias SET edits_pending = 0
WHERE id IN (
  SELECT id FROM label_alias
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE medium SET edits_pending = 0
WHERE id IN (
  SELECT id FROM medium
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE medium_cdtoc SET edits_pending = 0
WHERE id IN (
  SELECT id FROM medium_cdtoc
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE recording SET edits_pending = 0
WHERE id IN (
  SELECT id FROM recording
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE release SET edits_pending = 0
WHERE id IN (
  SELECT id FROM release
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE release_group SET edits_pending = 0
WHERE id IN (
  SELECT id FROM release_group
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE track SET edits_pending = 0
WHERE id IN (
  SELECT id FROM track
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE url SET edits_pending = 0
WHERE id IN (
  SELECT id FROM url
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE work SET edits_pending = 0
WHERE id IN (
  SELECT id FROM work
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

echo "UPDATE work_alias SET edits_pending = 0
WHERE id IN (
  SELECT id FROM work_alias
  WHERE now() - last_updated > '20 days'
  AND edits_pending > 0
);" | ./admin/psql ; sleep $[60 * 60]

