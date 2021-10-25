const SearchOverlay = props => {
    let typeCurrent;
    const handleSubmit = (event) => {
        event.preventDefault();
        const query = document.getElementById('searchInput');
        const limit = document.getElementById('limit');
        const method = document.getElementById('method');

        let methodUsed;
        if(method.value === 'Direct database search'){
            methodUsed = 'direct';
        }
        else if(method.value==='Indexed Search'){
            methodUsed = 'indexed';
        }
        else{
            methodUsed = 'advanced';
        }

        let limitUsed;
        if(limit.value === 'Upto 25'){
            limitUsed = '25';
        }
        else if(limit.value==='Upto 50'){
            limitUsed = '50';
        }
        else{
            limitUsed = '100';
        }
        if(query.value.trim().length<1){
            return false;
        }
        let searchType;
        typeCurrent = document.getElementById("type-selector").value;
        if(typeCurrent==='CD Stud'){
            searchType = "cdstub";
        }
        else if(typeCurrent === "Documentation"){
            searchType = "doc";
        }
        else{
            searchType = typeCurrent.replace(' ','_').toLowerCase()
        }
        window.open("https://musicbrainz.org/"+"search?type=" + searchType +
            "&query=" +query.value +
            "&limit="+ limitUsed +
            "&method=" + methodUsed, "_newTab");
        return false;
    }
    return(
        <div className={"box-collapse " + props.theme}>
            <div className="title-box-d">
                <h3 className="title-d">Advanced Search</h3>
            </div>
            <span className="close-box-collapse right-boxed bi bi-x" onClick={remove}/>
            <div className="box-collapse-wrap form">
                <form className="form-a" onSubmit={handleSubmit}>
                    <div className="row">
                        <div className="col-md-12 mb-2">
                            <div className="form-group">
                                <label className="pb-2" htmlFor="Type">Keywords</label>
                                <input id="searchInput" type="search" style={{textTransform: "capitalize"}}
                                       className="form-control form-control-lg form-control-a" placeholder="Query"/>
                            </div>
                        </div>
                        <div className="col-md-6 mb-2">
                            <div className="form-group mt-3">
                                <label className="pb-2" htmlFor="Type">Type</label>
                                <select id="type-selector" className="form-control form-select form-control-a">
                                    <option>Artist</option>
                                    <option>Release</option>
                                    <option>Recording</option>
                                    <option>Label</option>
                                    <option>Work</option>
                                    <option>Release Group</option>
                                    <option>Area</option>
                                    <option>Place</option>
                                    <option>Annotation</option>
                                    <option>CD Stud</option>
                                    <option>Editor</option>
                                    <option>Tag</option>
                                    <option>Instrument</option>
                                    <option>Series</option>
                                    <option>Event</option>
                                    <option>Documentation</option>
                                </select>
                            </div>
                        </div>
                        <div className="col-md-6 mb-2">
                            <div className="form-group mt-3">
                                <label className="pb-2" htmlFor="results">Result per Page</label>
                                <select id="limit" className="form-control form-select form-control-a">
                                    <option>Upto 25</option>
                                    <option>Upto 50</option>
                                    <option>Upto 100</option>
                                </select>
                            </div>
                        </div>
                        <div className="col-md-12 mb-2">
                            <div className="form-group mt-3">
                                <label className="pb-2" htmlFor="method">Method</label>
                                <select id="method" className="form-control form-select form-control-a">
                                    <option>Indexed Search</option>
                                    <option>Indexed Search with advanced query syntax</option>
                                    <option>Direct database search</option>
                                </select>
                            </div>
                        </div>
                        <div className="d-grid col-md-12">
                            <button type="submit" className="btn btn-b">Submit</button>
                        </div>
                    </div>
                </form>
            </div>

        </div>
    )
}

const remove = e => {
    e.preventDefault()
    document.body.classList.remove('box-collapse-open')
    document.body.classList.add('box-collapse-closed')
}

export default SearchOverlay;