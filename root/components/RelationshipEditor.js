import React from 'react';

const RelationshipEditor = () => {
  return (
    <div className="rel-editor-dialog" data-bind="with: activeDialog, delegatedHandler: ['click', 'keydown', 'change']" id="dialog">
      <div data-bind="template: dialogTemplate" data-change="changeEvent" data-click="clickEvent" data-keydown="keydownEvent" />

      <div className="buttons ui-helper-clearfix" style={{marginTop: '1em'}}>
        <button className="negative" data-bind="click: function () { $data.close(true) }" type="button">{l('Cancel')}</button>
        <div className="buttons-right" style={{float: 'right', textAlign: 'right'}}>
          <button className="positive" data-bind="disable: hasErrors() || loading(), click: function () { $data.accept() }" type="button">{l('Done')}</button>
        </div>
      </div>
    </div>
  );
};

export default RelationshipEditor;
