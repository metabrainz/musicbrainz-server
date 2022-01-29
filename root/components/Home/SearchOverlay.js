const SearchOverlay = props => {
  let typeCurrent;
  const handleSubmit = (event) => {
    event.preventDefault();
    const query = document.getElementById('searchInput');
    const limit = document.getElementById('limit');
    const method = document.getElementById('methodod');

    let methodUsed;
    if (method.value === 'Direct database search') {
      methodUsed = 'direct';
    } else if (method.value === 'Indexed Search') {
      methodUsed = 'indexed';
    } else {
      methodUsed = 'advanced';
    }

    let limitUsed;
    if (limit.value === 'Upto 25') {
      limitUsed = '25';
    } else if (limit.value === 'Upto 50') {
      limitUsed = '50';
    } else {
      limitUsed = '100';
    }
    if (query.value.trim().length < 1) {
      return false;
    }
    let searchType;
    typeCurrent = document.getElementById('type-selector').value;
    if (typeCurrent === 'CD Stud') {
      searchType = 'cdstub';
    } else if (typeCurrent === 'Documentation') {
      searchType = 'doc';
    } else {
      searchType = typeCurrent.replace(' ', '_').toLowerCase();
    }
    window.open('https://musicbrainz.org/' + 'search?type=' + searchType +
            '&query=' + query.value +
            '&limit=' + limitUsed +
            '&method=' + methodUsed, '_newTab');
    return false;
  };
  return (
    <div className={'box-collapse ' + props.theme}>
      <span
        className="close-box-collapse right-boxed bi bi-x"
        onClick={remove}
      />

      <div className="row">
        <div className="title-box-d">
          <h3 className="title-d">
            {l(`Advanced Search`)}
          </h3>
        </div>
        <div className="box-collapse-wrap form">
          <form className="form-a" onSubmit={handleSubmit}>
            <div className="row">
              <div className="col-md-12 mb-2">
                <div className="form-group">
                  <label className="pb-2" htmlFor="Type">
                    {l(`Keywords`)}
                  </label>
                  <input
                    className="form-control form-control-lg form-control-a"
                    id="searchInput"
                    placeholder="Query"
                    style={{textTransform: 'capitalize'}}
                    type="search"
                  />
                </div>
              </div>
              <div className="col-md-6 mb-2">
                <div className="form-group mt-3">
                  <label className="pb-2" htmlFor="Type">
                    {l(`Type`)}
                  </label>
                  <select
                    className="form-control form-select form-control-a"
                    id="type-selector"
                  >
                    <option>
                      {l(`Artist`)}
                    </option>
                    <option>
                      {l(`Release`)}
                    </option>
                    <option>
                      {l(`Recording`)}
                    </option>
                    <option>
                      {l(`Label`)}
                    </option>
                    <option>
                      {l(`Work`)}
                    </option>
                    <option>
                      {l(`Release Group`)}
                    </option>
                    <option>
                      {l(`Area`)}
                    </option>
                    <option>
                      {l(`Place`)}
                    </option>
                    <option>
                      {l(`Annotation`)}
                    </option>
                    <option>
                      {l(`CD Stub`)}
                    </option>
                    <option>
                      {l(`Editor`)}
                    </option>
                    <option>
                      {l(`Tag`)}
                    </option>
                    <option>
                      {l(`Instrument`)}
                    </option>
                    <option>
                      {l(`Series`)}
                    </option>
                    <option>
                      {l(`Event`)}
                    </option>
                    <option>{l(`Documentation`)}</option>
                  </select>
                </div>
              </div>
              <div className="col-md-6 mb-2">
                <div className="form-group mt-3">
                  <label className="pb-2" htmlFor="results">
                    {l(`Result per Page`)}
                  </label>
                  <select
                    className="form-control form-select form-control-a"
                    id="limit"
                  >
                    <option>
                      {l(`Upto 25`)}
                    </option>
                    <option>
                      {l(`Upto 50`)}
                    </option>
                    <option>
                      {l(`Upto 100`)}
                    </option>
                  </select>
                </div>
              </div>
              <div className="col-md-12 mb-2">
                <div className="form-group mt-3">
                  <label className="pb-2" htmlFor="method">
                    {l(`Method`)}
                  </label>
                  <select
                    className="form-control form-select form-control-a"
                    id="method"
                  >
                    <option>
                      {l(`Indexed Search`)}
                    </option>
                    <option>
                      {l(`Indexed Search with advanced query syntax`)}
                    </option>
                    <option>
                      {l(`Direct database search`)}
                    </option>
                  </select>
                </div>
              </div>
              <div className="d-grid col-md-12">
                <button className="btn btn-b" type="submit">
                  {l(`Submit`)}
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <div className="row">
        <div className="title-box-d">
          <h3 className="title-d">
            {l(`Tag Lookup`)}
          </h3>
        </div>
        <div className="box-collapse-wrap form">
          <form className="form-a" onSubmit={handleSubmit}>
            <div className="row">
              <div className="col-md-12 mb-2">
                <label className="pb-2" htmlFor="Type">
                  {l(`Artist`)}
                </label>
                <input
                  className="form-control form-control-lg form-control-a"
                />
              </div>
              <div className="col-md-12 mb-2">
                <label className="pb-2" htmlFor="Type">
                  {l(`Release`)}
                </label>
                <input
                  className="form-control form-control-lg form-control-a"
                />
              </div>
              <div className="col-md-12 mb-2">
                <label className="pb-2" htmlFor="Type">
                  {l(`Track Number`)}
                </label>
                <input
                  className="form-control form-control-lg form-control-a"
                />
              </div>
              <div className="col-md-12 mb-2">
                <label className="pb-2" htmlFor="Type">
                  {l(`Track`)}
                </label>
                <input
                  className="form-control form-control-lg form-control-a"
                />
              </div>
              <div className="col-md-12 mb-2">
                <label className="pb-2" htmlFor="Type">
                  {l(`Duration`)}
                </label>
                <input
                  className="form-control form-control-lg form-control-a"
                />
              </div>
              <div className="col-md-12 mb-2">
                <label className="pb-2" htmlFor="Type">
                  {l(`Filename`)}
                </label>
                <input
                  className="form-control form-control-lg form-control-a"
                />
              </div>
              <div className="d-grid col-md-12">
                <button className="btn btn-b" type="submit">
                  {l(`Submit`)}
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

const remove = e => {
  e.preventDefault();
  document.body.classList.remove('box-collapse-open');
  document.body.classList.add('box-collapse-closed');
  return;
};

export default SearchOverlay;
