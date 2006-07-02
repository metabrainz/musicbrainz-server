// Is innerHTML standard?  If not, use something like:
// document.getElementById(...).firstChild.nodeValue = text;
function artistChangeBeginEnd(begin, end)
{
  document.getElementById('begindate_text').innerHTML = begin;
  document.getElementById('enddate_text').innerHTML = end;
}

// See the ARTIST_TYPE_* constants
function artistTypeChanged(selection)
{
  switch (selection) {
  default:
  case '0':
  case '3':
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
