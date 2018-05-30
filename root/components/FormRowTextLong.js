/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import FormRowText from './FormRowText';

type Props = {
  +field: FieldT<string>,
  +label: string,
  +required?: boolean,
};

const FormRowTextLong = (props: Props) => (
  <FormRowText size={47} {...props} />
);

export default FormRowTextLong;
