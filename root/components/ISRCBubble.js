import React from 'react';

const ISRCBubble = () => {
  return (
    <div className="bubble" id="isrcs-bubble">
      <p>{l('You are about to add an ISRC to this recording. The ISRC must be entered in standard <code>CCXXXYYNNNNN</code> format:')}</p>
      <ul>
        <li>{l('"CC" is the appropriate for the registrant two-character country code.')}</li>
        <li>{l('"XXX" is a three character alphanumeric registrant code, uniquely identifying the organisation which registered the code.')}</li>
        <li>{l('"YY" is the last two digits of the year of registration.')}</li>
        <li>{l('"NNNNN" is a unique 5-digit number identifying the particular sound recording.')}</li>
      </ul>
    </div>
  );
};

export default ISRCBubble;
