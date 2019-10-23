/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import LinkSearchableProperty from './LinkSearchableProperty';

type Props = {
  +entityType: string,
  +language: LanguageT,
};

const LinkSearchableLanguage = ({entityType, language}: Props) => (
  <LinkSearchableProperty
    entityType={entityType}
    searchField="lang"
    searchValue={language.iso_code_3 || ''}
    text={l_languages(language.name)}
  />
);

export default LinkSearchableLanguage;
