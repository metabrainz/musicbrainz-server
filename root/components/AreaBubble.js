import React from 'react';

const AreaBubble = () => {
  return (
    <div className="bubble" id="area-bubble">
      <p data-bind="html: $data.selectionMessage()" />
    </div>
  );
};

export default AreaBubble;
