/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FieldErrors from '../../../../components/FieldErrors';
import SelectField from '../../../../components/SelectField';
import {addColonText} from '../i18n/addColon';

export type FilterFormT = $ReadOnly<{
  ...FormT<{
    +artist_credit_id: ReadOnlyFieldT<number>,
    +country_id?: ReadOnlyFieldT<number>,
    +date?: ReadOnlyFieldT<string>,
    +name: ReadOnlyFieldT<string>,
    +role_type?: ReadOnlyFieldT<number>,
    +type_id?: ReadOnlyFieldT<number>,
  }>,
  entity_type: 'recording' | 'release' | 'release_group',
  options_artist_credit_id: SelectOptionsT,
  options_country_id: SelectOptionsT,
  options_role_type?: SelectOptionsT,
  options_type_id?: SelectOptionsT,
}>;

type Props = {
  +form: FilterFormT,
};

function getSubmitText(type: string) {
  switch (type) {
    case 'recording':
      return l('Filter recordings');
    case 'release':
      return l('Filter releases');
    case 'release_group':
      return l('Filter release groups');
    case 'work':
      return l('Filter works');
  }
  return '';
}

const FilterForm = ({form}: Props): React.Element<'div'> => {
  const typeIdField = form.field.type_id;
  const typeIdOptions = form.options_type_id;
  const artistCreditIdField = form.field.artist_credit_id;
  const artistCreditIdOptions = form.options_artist_credit_id;
  const countryIdOptions = form.options_country_id;
  const countryIdField = form.field.country_id;
  const dateField = form.field.date;
  const roleTypeField = form.field.role_type;
  const roleTypeOptions = form.options_role_type;

  return (
    <div id="filter">
      <form method="get">
        <table>
          <tbody>
            {typeIdField && typeIdOptions ? (
              <tr>
                <td>
                  {addColonText(l('Type'))}
                </td>
                <td>
                  <SelectField
                    field={typeIdField}
                    options={{grouped: false, options: typeIdOptions}}
                    style={{maxWidth: '40em'}}
                    uncontrolled
                  />
                </td>
              </tr>
            ) : null}

            {artistCreditIdField && artistCreditIdOptions ? (
              <tr>
                <td>
                  {l('Artist credit:')}
                </td>
                <td>
                  <SelectField
                    field={artistCreditIdField}
                    options={{
                      grouped: false,
                      options: artistCreditIdOptions,
                    }}
                    style={{maxWidth: '40em'}}
                    uncontrolled
                  />
                </td>
              </tr>
            ) : null}

            <tr>
              <td>{addColonText(l('Name'))}</td>
              <td>
                <input
                  defaultValue={form.field.name.value}
                  name={form.field.name.html_name}
                  size="47"
                  type="text"
                />
              </td>
            </tr>

            {roleTypeField && roleTypeOptions ? (
              <tr>
                <td>
                  {addColonText(l('Role'))}
                </td>
                <td>
                  <SelectField
                    field={roleTypeField}
                    options={{
                      grouped: false,
                      options: roleTypeOptions,
                    }}
                    style={{maxWidth: '40em'}}
                    uncontrolled
                  />
                </td>
              </tr>
            ) : null}

            {countryIdField && countryIdOptions ? (
              <tr>
                <td>
                  {addColonText(l('Country'))}
                </td>
                <td>
                  <SelectField
                    field={countryIdField}
                    options={{
                      grouped: false,
                      options: countryIdOptions,
                    }}
                    style={{maxWidth: '40em'}}
                    uncontrolled
                  />
                </td>
              </tr>
            ) : null}

            {dateField ? (
              <tr>
                <td>
                  {addColonText(l('Date'))}
                </td>
                <td>
                  <input
                    defaultValue={dateField.value ?? ''}
                    name={dateField.html_name}
                    size="47"
                    type="text"
                  />
                  <FieldErrors field={dateField} />
                </td>
              </tr>
            ) : null}

            <tr>
              <td />
              <td>
                <span className="buttons">
                  <button className="submit positive" type="submit">
                    {getSubmitText(form.entity_type)}
                  </button>
                  <button
                    className="submit negative"
                    name="filter.cancel"
                    type="submit"
                    value="1"
                  >
                    {l('Cancel')}
                  </button>
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </form>
    </div>
  );
};

export default FilterForm;
