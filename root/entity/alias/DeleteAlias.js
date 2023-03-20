/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EnterEdit from '../../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../../static/scripts/edit/components/EnterEditNote.js';
import chooseLayoutComponent from '../../utility/chooseLayoutComponent.js';

import type {AliasDeleteFormT} from './types.js';

type Props = {
  +alias: AnyAiasT,
  +entity: EntityWithAliasesT,
  +form: AliasDeleteFormT,
  +type: string,
};

const DeleteAlias = ({
  alias,
  entity,
  form,
  type,
}: Props): React$MixedElement => {
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

      <form method="post">
        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </form>
    </LayoutComponent>
  );
};

export default DeleteAlias;
