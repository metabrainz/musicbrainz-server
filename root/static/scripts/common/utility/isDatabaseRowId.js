/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * The implementation should match `is_database_row_id` from
 * MusicBrainz::Server:Validation.
 */

export const MAX_POSTGRES_INT = 2_147_483_647;

export default function isDatabaseRowId(input: mixed): boolean %checks {
  return (
    typeof input === 'number' &&
    input > 0 &&
    input <= MAX_POSTGRES_INT
  );
}
