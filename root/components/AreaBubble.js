import React from 'react';

const AreaBubble = () => {
  return (
    <div className="bubble" id="area-bubble">
      <div data-bind="with: target() && target().area">
        <p data-bind="html: $data.selectionMessage()" />
      </div>
    </div>
  );
};

export default AreaBubble;
