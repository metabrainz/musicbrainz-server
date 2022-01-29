import {useEffect, useState} from 'react';

const Blog = () => {
  const [blogDetails, setBlogDetails] = useState([{}]);

  const fetchBlogDetails = async () =>{
    let response = await fetch(`https://public-api.wordpress.com/rest/v1.1/sites/blog.metabrainz.org/posts/`);
    response = await response.json();
    const objectArray = [];
    for (let postIndex = 0; postIndex <= 7; postIndex++) {
      const object = {};
      object.id = response.posts[postIndex].ID;
      object.title = response.posts[postIndex].title;
      object.link = response.posts[postIndex].URL;
      objectArray.push(object);
    }
    setBlogDetails(objectArray);
  };
  useEffect(()=>{
    fetchBlogDetails();
  }, []);

  return (
    <div className="card">
      <img
        alt="Blogs Logo"
        className="card-img-top"
        height="48"
        src="/assets/img/blogs.svg"
        width="128"
      />
      <div className="card-body">
        <h5 className="card-title text-center">
          <span className=" color-purple">
            {l(`News`)}
          </span>
          {l(`&`)}
          <span className="color-orange">
            {l(`Updates`)}
          </span>
        </h5>
      </div>
      <ul className="list-group list-group-flush">
        {blogDetails.map(post => (
          <li className="list-group-item" key={post.id}>
            <a
              className="card-link"
              href={post.link}
              rel="noopener noreferrer"
              target="_blank"
            >
              {post.title}
            </a>
          </li>
      ))}

      </ul>
      <div className="card-body align-items-center
      d-flex justify-content-center"
      >
        <a
          className="card-link"
          href="https://twitter.com/MusicBrainz"
          rel="noopener noreferrer"
          target="_blank"
        >
          {' '}
          <i className="fab fa-twitter" />
        </a>
        <a
          className="card-link"
          href="https://blog.metabrainz.org"
          rel="noopener noreferrer"
          target="_blank"
        >
          {' '}
          <i className="bi bi-rss-fill" />
        </a>
        <a
          className="card-link"
          href="https://community.metabrainz.org"
          rel="noopener noreferrer"
          target="_blank"
        >
          {l(`Community Forum`)}
        </a>
      </div>
    </div>
  );
};

export default Blog;
