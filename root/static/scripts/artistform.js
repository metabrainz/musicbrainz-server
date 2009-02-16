// Used on: /root/artist/create.tt
// Used on: /root/artist/edit.tt

/**************************************************
 *  Attach trigger to the change event for the
 *  artist type selector.
 *************************************************/
$(document).ready(function(){
    $('#id_artist_type').change(artistTypeChanged);
});

/**************************************************
 *  Changes the label descriptions depending upon
 *  the artist type.
 *************************************************/
function artistChangeBeginEnd(begin, end)
{
    $('#id_label_start').text(begin);
    $('#id_label_end').text(end);
}

/**************************************************
 *  Sets the label descriptions depending upon
 *  the artist type.
 *  Unknown: 0
 *  Person: 1
 *  Group: 2
 *************************************************/
function artistTypeChanged()
{
  switch ($('#id_artist_type').val()) {
  default:
  case '0':
    artistChangeBeginEnd('Begin Date', 'End Date');
    break;
  case '1':
    artistChangeBeginEnd('Born', 'Deceased');
    break;
  case '2':
    artistChangeBeginEnd('Founded', 'Dissolved');
    break;
  }
}
