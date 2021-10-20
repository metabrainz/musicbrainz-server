import React from "react";
import Carousel from "react-multi-carousel";
import axios from "axios";

const responsive = {
    desktop: {
        breakpoint: { max: 3000, min: 1024 },
        items: 3
    },
    tablet: {
        breakpoint: { max: 1024, min: 464 },
        items: 2
    },
    mobile: {
        breakpoint: { max: 464, min: 0 },
        items: 1
    }
};

class Intro extends React.Component {

    state = {
        additionalTransform: 0,
        posts: [],
    };

    componentDidMount() {
        axios
            .get(`https://itunes.apple.com/us/rss/topalbums/limit=100/json`)
            .then(res => {
                this.setState({ posts: res.data.feed.entry });
            });
    }

    render() {
        const chipData = [
            {key: 0, label: 'Artist'},
            {key: 1, label: 'Release'},
            {key: 2, label: 'Recording'},
            {key: 3, label: 'Label'},
            {key: 4, label: 'Work'},
            {key: 5, label: 'Release Group'},
            {key: 6, label: 'Area'},
            {key: 7, label: 'Place'},
            {key: 8, label: 'Annotation'},
            {key: 9, label: 'CD Stud'},
            {key: 10, label: 'Editor'},
            {key: 11, label: 'Tag'},
            {key: 12, label: 'Instrument'},
            {key: 13, label: 'Series'},
            {key: 14, label: 'Event'},
            {key: 15, label: 'Documentation'},
        ];

        let theme, typeCurrent = "Artist";
        if (this.props.isDarkThemeActive) {
            theme = "theme-dark";
        }
        else {
            theme = "theme-light";
        }

        function onChipClick(type) {
            const indexPrev = chipData.map(e => e.label).indexOf(typeCurrent);
            const elementPrev = document.getElementById("type"+indexPrev);
            elementPrev.className = "chip";

            typeCurrent = type;

            const indexNew = chipData.map(e => e.label).indexOf(type);
            const elementNew = document.getElementById("type"+indexNew);
            elementNew.className = "chip chip--active";
        }

        function searchButtonClick() {
            const query = document.getElementById('searchInputMain');
            console.log(query.value);
            if(query.value.trim().length<1){
                return;
            }
            let searchType;
            if(typeCurrent==='CD Stud'){
                searchType = "cdstub";
            }
            else if(typeCurrent === "Documentation"){
                searchType = "doc";
            }
            else{
                searchType = typeCurrent.replace(' ','_').toLowerCase()
            }
            window.open("https://musicbrainz.org/"+"search?type=" + searchType + "&query=" +query.value, "_newTab");
        }

        return (
            <section id="intro" className={"intro d-flex align-items-center "+theme}>
                <div className="container">
                    <div className="row">
                        <div className="col-lg-9 d-flex flex-column justify-content-center">
                            <h1 data-aos="fade-up" style={{marginTop: "20px"}}>The Music Database</h1>
                            <h2 data-aos="fade-up" data-aos-delay="400" >
                                World&apos;s Biggest Open Source Music Database
                            </h2>

                            <div className="row search-margins">
                                <div className="col-8 col-md-10">
                                    <input type="search" name="query"
                                           id="searchInputMain"
                                           className={"form-control special-font"}
                                           style={{textTransform: "capitalize"}}
                                           onKeyPress={event => {
                                               if (event.key === "Enter") {
                                                   const query = document.getElementById('searchInputMain');
                                                   console.log(query.value);
                                                   if(query.value.trim().length<1){
                                                       return false;
                                                   }
                                                   let searchType;
                                                   if(typeCurrent==='CD Stud'){
                                                       searchType = "cdstub";
                                                   }
                                                   else if(typeCurrent === "Documentation"){
                                                       searchType = "doc";
                                                   }
                                                   else{
                                                       searchType = typeCurrent.replace(' ','_').toLowerCase()
                                                   }
                                                   window.open("https://musicbrainz.org/"+"search?type=" + searchType + "&query=" +query.value, "_newTab");
                                                   return false;
                                               }
                                           }}
                                           placeholder="Search 41,054,421 Entities"/>
                                </div>
                                <div className="col-4 col-md-2">
                                    <button type="button" className="btn btn-b-n" onClick={searchButtonClick}>
                                        <i className="fab fa-searchengin"/>
                                    </button>
                                    <button type="button" className="btn btn-b-n">
                                        <i className="bi bi-upc-scan"/>
                                    </button>
                                </div>
                            </div>
                            <div className="choiceChips">
                                {
                                    chipData.map((data) => {
                                        if(data.key===0){
                                            return <div id={"type"+data.key} className="chip chip--active" onClick={() => onChipClick(data.label)}>{data.label}</div>
                                        }
                                        return (
                                            // eslint-disable-next-line react/jsx-key
                                            <div id={"type"+data.key} className="chip" onClick={() => onChipClick(data.label)}>{data.label}</div>
                                        );
                                    })
                                }
                            </div>
                            <Carousel
                                ssr={false}
                                ref={el => (this.Carousel = el)}
                                partialVisbile={false}
                                infinite={true}
                                autoPlay={true}
                                autoPlaySpeed={6000}
                                itemClass="slider-image-item"
                                responsive={responsive}
                                containerClass="carousel-container-with-scrollbar"
                                additionalTransform={-this.state.additionalTransform}
                                beforeChange={nextSlide => {
                                    if (nextSlide !== 0 && this.state.additionalTransform !== 150) {
                                        this.setState({additionalTransform: 150});
                                    }
                                    if (nextSlide === 0 && this.state.additionalTransform === 150) {
                                        this.setState({additionalTransform: 0});
                                    }
                                }}
                            >
                                {
                                    this.state.posts ? this.state.posts.map((artwork, indx) => {
                                        return (

                                            <div className="card text-left mt-5" key={indx}>
                                                <img style={{width: '100%', height: '250px', objectFit: 'cover'}}
                                                     src={artwork["im:image"][2].label} alt="Alt text"/>
                                            </div>

                                        )
                                    }) :  <div className="card text-left mt-5" key="1">
                                        <img style={{width: '100%', height: '250px', objectFit: 'cover'}}
                                             src="assets/img/demo.jpg" alt="Alt text"/>
                                    </div>
                                }
                            </Carousel>
                        </div>
                        <div className={"col-lg-3 d-none d-lg-block"}>
                            <div className="card">
                                <img className="card-img-top" src="assets/img/blogs.svg" alt="Blogs Logo"/>
                                    <div className="card-body">
                                        <h5 className="card-title text-center"><span className=" color-purple">News</span> & <span className="color-orange">Updates</span></h5>
                                    </div>
                                    <ul className="list-group list-group-flush">
                                        <li className={"list-group-item"}><a href="https://blog.metabrainz.org/2021/10/07/picard-2-7-beta-1/" target="_blank" rel="noopener noreferrer" className="card-link">Picard 2.7 Beta 1</a></li>
                                        <li className={"list-group-item"}><a href="https://blog.metabrainz.org/2021/10/06/picard-2-6-4-released/" className="card-link" target="_blank" rel="noopener noreferrer">Picard 2.6.4 released</a></li>
                                        <li className={"list-group-item"}><a href="https://blog.metabrainz.org/2021/10/04/musicbrainz-server-update-2021-10-04/" className="card-link" target="_blank" rel="noopener noreferrer">MusicBrainz Server update, 2021-10-04</a></li>
                                        <li className={"list-group-item"}><a href="https://blog.metabrainz.org/2021/09/20/musicbrainz-server-update-2021-09-20/" className="card-link" target="_blank" rel="noopener noreferrer">MusicBrainz Server update, 2021-09-20</a></li>
                                        <li className={"list-group-item"}><a href="https://blog.metabrainz.org/2021/09/06/musicbrainz-server-update-2021-09-06/" className="card-link" target="_blank" rel="noopener noreferrer">MusicBrainz Server update, 2021-09-06</a></li>
                                        <li className={"list-group-item"}><a href="https://blog.metabrainz.org/2021/09/01/acoustic-similarity-in-acousticbrainz/" className="card-link" target="_blank" rel="noopener noreferrer">Acoustic similarity in AcousticBrainz</a></li>
                                        <li className={"list-group-item"}><a href="https://blog.metabrainz.org/2021/08/23/gsoc-2021-pin-recordings-and-critiquebrainz-integration-in-listenbrainz/" className="card-link" target="_blank" rel="noopener noreferrer">GSoC 2021: Pin Recordings and CritiqueBrainz Integration in ListenBrainz</a></li>
                                    </ul>
                                <div className="card-body align-items-center d-flex justify-content-center">
                                    <a href="https://twitter.com/MusicBrainz" target="_blank" rel="noopener noreferrer" className="card-link"> <i className="fab fa-twitter"/></a>
                                    <a href="https://blog.metabrainz.org" className="card-link" target="_blank" rel="noopener noreferrer"> <i className="bi bi-rss-fill"/></a>
                                    <a href="https://community.metabrainz.org" className="card-link" target="_blank" rel="noopener noreferrer">Community Forum</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        )
    }
}

export default Intro;