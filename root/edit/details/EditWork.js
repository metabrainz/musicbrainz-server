/*
 * @flow strict-local
 * Copyright (C) 2020 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import {commaOnlyListText}
  from '../../static/scripts/common/i18n/commaOnlyList.js';
import localizeLanguageName
  from '../../static/scripts/common/i18n/localizeLanguageName.js';
import Diff from '../../static/scripts/edit/components/edit/Diff.js';
import DiffSide from '../../static/scripts/edit/components/edit/DiffSide.js';
import FullChangeDiff
  from '../../static/scripts/edit/components/edit/FullChangeDiff.js';
import WordDiff from '../../static/scripts/edit/components/edit/WordDiff.js';
import {DELETE, INSERT} from '../../static/scripts/edit/utility/editDiff.js';

type Props = {
  +edit: EditWorkEditT,
};

const localizeLanguage =
  (language: LanguageT) => localizeLanguageName(language, true);

const EditWork = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const comment = display.comment;
  const iswc = display.iswc;
  const name = display.name;
  const type = display.type;
  const languages = display.languages;
  const attributes = display.attributes;
  const attributeNames = attributes
    ? Object.keys(attributes).sort()
    : null;

  return (
    <table className="details edit-work">
      <tr>
        <th>{addColonText(l('Work'))}</th>
        <td colSpan="2">
          <DescriptiveLink entity={display.work} />
        </td>
      </tr>
      {name ? (
        <WordDiff
          label={addColonText(l('Name'))}
          newText={name.new}
          oldText={name.old}
        />
      ) : null}
      {comment ? (
        <WordDiff
          label={addColonText(l('Disambiguation'))}
          newText={comment.new ?? ''}
          oldText={comment.old ?? ''}
        />
      ) : null}
      {iswc ? (
        <Diff
          label={addColonText(l('ISWC'))}
          newText={iswc.new ?? ''}
          oldText={iswc.old ?? ''}
        />
      ) : null}
      {type ? (
        <FullChangeDiff
          label={addColonText(l('Work type'))}
          newContent={
            type.new?.name ? lp_attributes(type.new.name, 'work_type') : ''
          }
          oldContent={
            type.old?.name ? lp_attributes(type.old.name, 'work_type') : ''
          }
        />
      ) : null}
      {languages ? (
        <Diff
          label={addColonText(l('Lyrics Languages'))}
          newText={commaOnlyListText(
            languages.new.map(localizeLanguage),
          )}
          oldText={commaOnlyListText(
            languages.old.map(localizeLanguage),
          )}
          split=", "
        />
      ) : null}
      {attributeNames ? attributeNames.map((attributeName) => {
        /*:: if (!attributes) throw 'impossible'; */
        const attributeDiff = attributes[attributeName];
        return (
          <tr key={attributeName}>
            <th>
              {addColonText(attributeName)}
            </th>
            <td className="old">
              {attributeDiff.old.length > 0 ? (
                <ul>
                  {attributeDiff.old.map((attribute, index) => (
                    <li key={attribute}>
                      <DiffSide
                        filter={DELETE}
                        newText={attributeDiff.new[index] ?? ''}
                        oldText={attribute}
                        split="\s+"
                      />
                    </li>
                  ))}
                </ul>
              ) : null}
            </td>
            <td className="new">
              {attributeDiff.new.length > 0 ? (
                <ul>
                  {attributeDiff.new.map((attribute, index) => (
                    <li key={attribute}>
                      <DiffSide
                        filter={INSERT}
                        newText={attribute}
                        oldText={attributeDiff.old[index] ?? ''}
                        split="\s+"
                      />
                    </li>
                  ))}
                </ul>
              ) : null}
            </td>
          </tr>
        );
      }) : null}
    </table>
  );
};

export default EditWork;
