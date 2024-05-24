/*
 * @flow strict
 * Copyright (C) 2020 Anirudh Jain
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import {commaOnlyListText} from
  '../../static/scripts/common/i18n/commaOnlyList.js';
import localizeLanguageName
  from '../../static/scripts/common/i18n/localizeLanguageName.js';

component AddWork(edit: AddWorkEditT) {
  const display = edit.display_data;
  const attributes:
    $NonMaybeType<AddWorkEditT['display_data']['attributes']> =
    display.attributes ?? {};
  const type = display.type;
  const language = display.language;
  const languages = display.languages;
  return (
    <>
      <table className="details">
        <tr>
          <th>{addColonText(l('Work'))}</th>
          <td><EntityLink entity={display.work} /></td>
        </tr>
      </table>
      <table className="details add-work">
        <tr>
          <th>{addColonText(l('Name'))}</th>
          <td>{display.name}</td>
        </tr>
        {display.comment ? (
          <tr>
            <th>{addColonText(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ) : null}
        {display.iswc ? (
          <tr>
            <th>{addColonText(l('ISWC'))}</th>
            <td>{display.iswc}</td>
          </tr>
        ) : null}
        {type ? (
          <tr>
            <th>{addColonText(l('Type'))}</th>
            <td>{lp_attributes(type.name, 'work_type')}</td>
          </tr>
        ) : null}
        {language ? (
          <tr>
            <th>{addColonText(l('Language'))}</th>
            <td>{localizeLanguageName(language, true)}</td>
          </tr>
        ) : null}
        {languages && languages.length ? (
          <tr>
            <th>{addColonText(l('Lyrics languages'))}</th>
            <td>
              {commaOnlyListText(languages.map(
                language => localizeLanguageName(language, true),
              ))}
            </td>
          </tr>
        ) : null}
        {Object.keys(attributes).sort().map((attributeName) => (
          <tr key={attributeName}>
            <th>
              {addColonText(lp_attributes(
                attributeName,
                'work_attribute_type',
              ))}
            </th>
            <td>
              <ul>
                {attributes[attributeName].map((attribute) => (
                  <li key={
                    String(attribute.typeID) +
                    '-' +
                    String(attribute.value_id ?? attribute.value)}
                  >
                    {attribute.value_id == null ? attribute.value
                      : lp_attributes(
                        attribute.value,
                        'work_attribute_type_allowed_value',
                      )}
                  </li>
                ))}
              </ul>
            </td>
          </tr>
        ))}
      </table>
    </>
  );
}

export default AddWork;
