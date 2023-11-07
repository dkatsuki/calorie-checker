
import queryParser from "query-string-parser";

class Ajax {
  constructor() {
    // queryParser.toQuery(yourQueryString)
    // queryParser.fromQuery(yourQueryString)
  }

  newXhr = () => {
    return(new XMLHttpRequest());
  }

  getCsrfToken = () => {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    return(csrfToken);
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

  post = (callback, requestPath, data= {}) => {
    const xhr = this.newXhr();
    xhr.open('POST', requestPath + '.json');
    xhr.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
    xhr.setRequestHeader('X-CSRF-Token', this.getCsrfToken());
    xhr.onload = () => {
      if (xhr.status === 200) {
        const response = JSON.parse(xhr.responseText);
        callback(response);
      } else {
        console.error('Request failed. Returned status of ' + xhr.status);
        callback(xhr.responseText);
      }
    };
    xhr.send(JSON.stringify(data));
  };
}

window.ajax = new Ajax();