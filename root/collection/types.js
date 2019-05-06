/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type CollectionFormT = FormT<{|
  +description: FieldT<string>,
  +name: FieldT<string>,
  +public: FieldT<boolean>,
  +type_id: FieldT<number>,
|}>;
