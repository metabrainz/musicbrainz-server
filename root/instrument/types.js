/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type InstrumentDeleteFormT = FormT<{
  +edit_note: ReadOnlyFieldT<string>,
  +make_votable: ReadOnlyFieldT<boolean>,
}>;
