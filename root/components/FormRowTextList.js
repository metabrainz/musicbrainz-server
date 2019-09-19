// @flow
import React from 'react';

import FormRow from './FormRow';
import FieldErrors from './FieldErrors';

type Unit = {
  has_errors: boolean,
  html_name: string,
  id: number,
  value: string,
};

type Props = {
  field: FieldT<Array<Unit>>,
  itemName: string,
  label: string,
};

const FormRowTextList = ({field, label, itemName}: Props) => {
  let script = '';
  if (field.value) {
    if (field.value.length > 0) {
      script = `MB.Form.TextList(${field.html_name}).init(${field.value.length})`;
    } else {
      script = `MB.Form.TextList(${field.html_name}).add('')`;
    }
  }
  return (
    <FormRow>
      <label>{label}</label>
      <div className="form-row-text-list">
        <div className={`text-list-row ${field.html_name}-template`} style={{display: 'none'}}>
          <input className="value with-button" type="text" value="" />
          <button className="nobutton icon remove-item" title={l(`Remove ${itemName}`)} type="button" />
        </div>
        {field.value ? field.value.map((item, index) => {
          return (
            <div className="text-list-row" key={index}>
              <input className="value with-button" name={`${field.html_name}.${index}`} type="text" value={item} />
              <button className="nobutton icon remove-item" title={l(`Remove ${itemName}`)} type="button" />
            </div>
          );
        }) : null}
        <div className="form-row-add">
          <button className="with-label add-item" type="button">
            {l(`Add ${itemName}`)}
          </button>
        </div>
      </div>
      <script dangerouslySetInnerHTML={{__html: script}} />
      <FieldErrors field={field} />
    </FormRow>
  );
};

export default FormRowTextList;
