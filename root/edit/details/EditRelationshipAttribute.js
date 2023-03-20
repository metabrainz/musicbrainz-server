/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import expand2react from '../../static/scripts/common/i18n/expand2react.js';
import localizeLinkAttributeTypeName
  from '../../static/scripts/common/i18n/localizeLinkAttributeTypeName.js';
import yesNo from '../../static/scripts/common/utility/yesNo.js';
import FullChangeDiff from
  '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';
import IntentionallyRawIcon
  from '../components/IntentionallyRawIcon.js';

type Props = {
  +edit: EditRelationshipAttributeEditT,
};

const EditRelationshipAttribute = ({edit}: Props): React$Element<'table'> => {
  const display = edit.display_data;
  const childOrder = display.child_order;
  const oldDescription = display.description.old ?? '';
  const newDescription = display.description.new ?? '';
  const descriptionChanges = newDescription !== oldDescription;
  const name = display.name;
  const parent = display.parent;
  const creditable = display.creditable;
  const freeText = display.free_text;
  const newParentName = parent?.new
    ? localizeLinkAttributeTypeName(parent.new)
    : '';
  const oldParentName = parent?.old
    ? localizeLinkAttributeTypeName(parent.old)
    : '';
  const rawIconSection = (
    <>
      {' '}
      <IntentionallyRawIcon />
    </>
  );

  return (
    <table className="details edit-relationship-attribute">
      {name.new === name.old ? (
        <tr>
          <th>{addColonText(l('Name'))}</th>
          <td colSpan="2">
            {l_relationships(name.old)}
          </td>
        </tr>
      ) : (
        <WordDiff
          extraNew={rawIconSection}
          extraOld={rawIconSection}
          label={addColonText(l('Name'))}
          newText={name.new}
          oldText={name.old}
        />
      )}

      {descriptionChanges ? (
        <WordDiff
          extraNew={nonEmpty(newDescription) ? rawIconSection : null}
          extraOld={nonEmpty(oldDescription) ? rawIconSection : null}
          label={addColonText(l('Description'))}
          newText={newDescription}
          oldText={oldDescription}
        />
      ) : nonEmpty(oldDescription) ? (
        <tr>
          <th>{addColonText(l('Description'))}</th>
          <td colSpan="2">
            {expand2react(l_relationships(oldDescription))}
          </td>
        </tr>
      ) : null}

      {parent?.old?.id === parent?.new?.id ? null : (
        <tr>
          <th>{addColonText(l('Parent'))}</th>
          <td className="old">{oldParentName}</td>
          <td className="new">{newParentName}</td>
        </tr>
      )}

      {childOrder ? (
        <WordDiff
          label={addColonText(l('Child order'))}
          newText={childOrder.new.toString()}
          oldText={childOrder.old.toString()}
        />
      ) : null}

      {creditable ? (
        <FullChangeDiff
          label={addColonText(l('Creditable'))}
          newContent={yesNo(creditable.new)}
          oldContent={yesNo(creditable.old)}
        />
      ) : null}

      {freeText ? (
        <FullChangeDiff
          label={addColonText(l('Free text'))}
          newContent={yesNo(freeText.new)}
          oldContent={yesNo(freeText.old)}
        />
      ) : null}
    </table>
  );
};

export default EditRelationshipAttribute;
