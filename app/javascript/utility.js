
import queryParser from "query-string-parser";

class Ajax {
  constructor() {
    // queryParser.toQuery(yourQueryString)
    // queryParser.fromQuery(yourQueryString)
  }

  newXhr = () => {
    return(new XMLHttpRequest());
  }

  get = (callback, requestPath, query = null) => {
    const xhr = this.newXhr();
    xhr.open('GET', requestPath + '.json' + '?' + queryParser.toQuery(query));
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = () => {
      if (xhr.status === 200) {
        const response = JSON.parse(xhr.responseText);
        callback(response);
      } else {
        console.error('Request failed. Returned status of ' + xhr.status);
        callback(xhr.responseText);
      }
    };
    xhr.send();
  };
}


window.ajax = new Ajax();