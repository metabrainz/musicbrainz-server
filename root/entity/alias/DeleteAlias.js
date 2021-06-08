/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import chooseLayoutComponent from '../../utility/chooseLayoutComponent';
import EnterEdit from '../../components/EnterEdit';
import EnterEditNote from '../../components/EnterEditNote';

import type {AliasDeleteFormT} from './types';

type Props = {
  +$c: CatalystContextT,
  +alias: AliasT,
  +entity: CoreEntityT,
  +form: AliasDeleteFormT,
  +type: string,
};

const DeleteAlias = ({
  $c,
  alias,
  entity,
  form,
  type,
}: Props): React.MixedElement => {
  const LayoutComponent = chooseLayoutComponent(type);
  const header = l('Remove alias');

  return (
    <LayoutComponent
      entity={entity}
      fullWidth
      title={header}
    >
      <h2>{header}</h2>
      <p>
        {exp.l(
          'You\'re removing the alias <em>{alias}</em>.',
          {alias: alias.name},
        )}
      </p>
      <p>
        {exp.l(
          `Please review the {doc|alias documentation}
           before entering this edit.`,
          {doc: '/doc/Aliases'},
        )}
      </p>

      <form action={$c.req.uri} method="post">
        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </form>
    </LayoutComponent>
  );
};

export default DeleteAlias;
