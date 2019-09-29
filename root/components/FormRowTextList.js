// @flow
/* eslint-disable react/jsx-no-bind */
import React, {useReducer} from 'react';
import mutate from 'mutate-cow';

import {pushField} from '../static/scripts/edit/utility/pushField';

import FormRow from './FormRow';
import FieldErrors from './FieldErrors';

type Props = {
  itemName: string,
  label: string,
  onAdd: (event: SyntheticEvent<HTMLButtonElement>) => void,
  onEdit: (index: number, value: string) => void,
  onRemove: (index: number) => void,
  textList: ReadOnlyRepeatableFieldT<ReadOnlyFieldT<string>>,
};

const FormRowTextList = ({
  textList,
  label,
  onAdd,
  onEdit,
  onRemove,
  itemName,
}: Props) => {
  function renderExistingTextList(textList, itemName) {
    return textList.field.map((iswc, index) => {
      return (
        <div className="text-list-row" key={iswc.id}>
          <input
            className="value with-button"
            name={`${textList.html_name}.${index}`}
            onChange={event => onEdit(index, event.currentTarget.value)}
            type="text"
            value={iswc.value}
          />
          {' '}
          <button
            className="nobutton icon remove-item"
            onClick={() => onRemove(index)}
            title={exp.l('Remove {item}', {item: itemName})}
            type="button"
          />
        </div>
      );
    });
  }

  return (
    <FormRow>
      <label>{label}</label>
      <div className="form-row-text-list">
        {renderExistingTextList(textList, itemName)}
        <div className="form-row-add">
          <button
            className="with-label add-item"
            onClick={onAdd}
            type="button"
          >
            {exp.l('Add {item}', {item: itemName})}
          </button>
        </div>
      </div>
      <FieldErrors field={textList} />
    </FormRow>
  );
};

export default FormRowTextList;
