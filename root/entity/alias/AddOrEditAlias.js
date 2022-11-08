/*
 * @flow strict-local
 * Copyright (C) 2019 Anirudh Jain
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import * as manifest from '../../static/manifest.mjs';
import AliasEditForm from '../../static/scripts/alias/AliasEditForm.js';
import {ENTITIES} from '../../static/scripts/common/constants.js';
import chooseLayoutComponent from '../../utility/chooseLayoutComponent.js';

import type {AliasEditFormT} from './types.js';

type Props = {
  +aliasTypes: SelectOptionsT,
  +entity: EntityWithAliasesT,
  +form: AliasEditFormT,
  +formType: string,
  +locales: SelectOptionsT,
  +type: string,
};

const AddOrEditAlias = ({
  aliasTypes,
  entity,
  form,
  formType,
  locales,
  type,
}: Props): React.MixedElement => {
  const LayoutComponent = chooseLayoutComponent(type);
  const header = formType === 'add'
    ? l('Add alias')
    : l('Edit alias');
  const entityProperties = ENTITIES[type];
  const searchHintType = entityProperties.aliases.search_hint_type;

  return (
    <LayoutComponent
      entity={entity}
      fullWidth
      title={header}
    >
      <h2>{header}</h2>
      <AliasEditForm
        aliasTypes={aliasTypes}
        entity={entity}
        form={form}
        locales={locales}
        searchHintType={searchHintType}
      />
      <div id="guesscase-options" />
      {manifest.js('alias', {async: 'async'})}
    </LayoutComponent>
  );
};

export default AddOrEditAlias;
