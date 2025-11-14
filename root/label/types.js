/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type LabelFormT = FormT<{
    +area: AreaFieldT,
    +area_id: FieldT<string>,
    +comment: FieldT<string>,
    +description: FieldT<string>,
    +edit_note: FieldT<string>,
    +ipi_codes: RepeatableFieldT<FieldT<string>>,
    +isni_codes: RepeatableFieldT<FieldT<string>>,
    +label_code: FieldT<string>,
    +make_votable: FieldT<boolean>,
    +name: FieldT<string | null>,
    +period: DatePeriodFieldT,
    +type_id: FieldT<string>,
  }>;
