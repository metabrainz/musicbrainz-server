export default function Header(props) {
  return (
    <>
      <nav
        className={
          'navbar navbar-default navbar-trans navbar-expand-lg fixed-top ' +
      props.theme}
      >
        <div className="container">
          <button
            aria-controls="navbarDefault"
            aria-expanded="false"
            aria-label="Toggle navigation"
            className="navbar-toggler collapsed"
            data-bs-target="#navbarDefault"
            data-bs-toggle="collapse"
            type="button"
          >
            <span />
            <span />
            <span />
          </button>
          <img
            alt="image"
            className="d-none d-lg-block image"
            height="60"
            src={'/img/meb-mini/' + props.projectName + '.svg'}
            width="180"
          />
          <div
            className="navbar-collapse collapse justify-content-center"
            id="navbarDefault"
          >
            <ul className="navbar-nav">
              <li className="nav-item dropdown">
                <a
                  aria-expanded="false"
                  aria-haspopup="true"
                  className="nav-link dropdown-toggle"
                  data-bs-toggle="dropdown"
                  href="#"
                  id="navbarDropdown"
                  role="button"
                >
                  {l(`English`)}
                </a>
                <div className="dropdown-menu">
                  <a className="dropdown-item ">
                    {l(`Deutsch`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`English`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`Français`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`Italiano`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`Nederlands`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`(Reset Language)`)}
                  </a>
                  <div className="dropdown-divider" />
                  <a className="dropdown-item">
                    {l(`Help Translate`)}
                  </a>
                </div>
              </li>

              <li className="nav-item">
                <a
                  className="nav-link "
                  href="https://musicbrainz.org/doc/MusicBrainz_Documentation"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l(`Docs`)}
                </a>
              </li>

              <li className="nav-item">
                <a
                  className="nav-link "
                  href="https://musicbrainz.org/doc/MusicBrainz_API"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l(`API`)}
                </a>
              </li>

              <li className="nav-item">
                <a
                  className="nav-link "
                  href="https://blog.metabrainz.org"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l(`Community`)}
                </a>
              </li>

              <li className="nav-item dropdown">
                <a
                  aria-expanded="false"
                  aria-haspopup="true"
                  className="nav-link dropdown-toggle"
                  data-bs-toggle="dropdown"
                  href="#"
                  id="navbarDropdown"
                  role="button"
                >
                  {l(`Username`)}
                </a>
                <div className="dropdown-menu">
                  <a className="dropdown-item ">
                    {l(`Profile`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`Register`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`Login`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`Applications`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`Subscriptions`)}
                  </a>
                  <a className="dropdown-item ">
                    {l(`Logout`)}
                  </a>
                </div>
              </li>
            </ul>

          </div>
          <div className="d-none d-lg-block general-margins">
            <input
              className="form-control"
              id="searchInputHeader"
              name="query"
              placeholder="Search"
              style={{textTransform: 'capitalize'}}
              type="search"
            />
          </div>

          <div
            className="d-none d-lg-block general-margins"
          >
            <select
              className="form-control"
              id="typeHeader"
              name="type"
            >
              {
                props.searchOptions.map((option) => (
                  <option>
                    {option}
                  </option>
                ))
              }
            </select>
          </div>
          <button
            className="btn btn-b-n"
            type="button"
          >
            <i className="bi bi-search" />
          </button>
        </div>
      </nav>
    </>
  );
}
