function getCSRFToken() {
  const CSRFSelector = document.querySelector('meta[name="csrf-token"]')
  if (CSRFSelector) {
    return CSRFSelector.getAttribute("content")
  } else {
    return null
  }
}

function callback(url, body) {
  fetch(url, {
    method: "POST",
    body: JSON.stringify(body),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-CSRF-Token": getCSRFToken()
    },
    credentials: 'same-origin'
  }).then(function(response) {
    if (response.ok) {
      window.location.replace("/")
    } else if (response.status < 500) {
      response.text().then(showMessage);
    } else {
      showMessage("Sorry, something wrong happened.");
    }
  });
}

function create(callbackUrl, credentialOptions) {
  navigator.credentials.create(credentialOptions).then(function(credential) {
    callback(callbackUrl, credential);
  }).catch(function(error) {
    console.error(error);
  });

  console.log("Creating new public key credential...");
}

function get(credentialOptions) {
  navigator.credentials.get({ "publicKey": credentialOptions }).then(function(credential) {
    callback("/session/callback", credential);
  }).catch(function(error) {
      console.error(error);
  });

  console.log("Getting public key credential...");
}

export { create, get }

