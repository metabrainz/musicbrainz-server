import React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink';
import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';

const AddWork = ({edit}) => {
  return (
    <>
      <table className="details">
        <tr>
          <th>{l('Work:')}</th>
          <td><EntityLink entity={edit.display_data.work} /></td>
        </tr>
      </table>
      <table className="details add-work">
        <tr>
          <th>{l('Name:')}</th>
          <td>{edit.display_data.name}</td>
        </tr>
        {edit.display_data.comment ? (
          <tr>
            <th>{addColon(l('Disambiguation'))}</th>
            <td>{edit.display_data.comment}</td>
          </tr>
        ) : null}
        {edit.display_data.iswc ? (
          <tr>
            <th>{l('ISWC:')}</th>
            <td>{edit.display_data.iswc}</td>
          </tr>
        ) : null}
        {edit.display_data.type ? (
          <tr>
            <th>{l('Type:')}</th>
            <td>{edit.display_data.type.name}</td>
          </tr>
        ) : null}
        {edit.display_data.language ? (
          <tr>
            <th>{l('Language:')}</th>
            <td>{edit.display_data.language.name}</td>
          </tr>
        ) : null}
        {edit.display_data.languages.size ? (
          <tr>
            <th>{addColon(l('Lyrics Languages'))}</th>
            <td>{commaOnlyList(edit.display_data.languages)}</td>
          </tr>
        ) : null}
      </table>
    </>
  );
};

export default AddWork;
