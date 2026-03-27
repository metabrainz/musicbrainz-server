/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {
  Iso3166VariantSnake,
} from '../static/scripts/edit/utility/iso3166.js';

export type AreaFormT = FormT<{
    +comment: FieldT<string>,
    +edit_note: FieldT<string>,
    +[key: Iso3166VariantSnake]: RepeatableFieldT<FieldT<string>>,
    +make_votable: FieldT<boolean>,
    +name: FieldT<string | null>,
    +period: DatePeriodFieldT,
    +type_id: FieldT<string>,
}>;
