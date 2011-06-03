BEGIN;

\copy link_type to '20110525_readwrite_link_type.dat';
\copy editor_preference to '20110525_editor_preference.dat';

COMMIT;
