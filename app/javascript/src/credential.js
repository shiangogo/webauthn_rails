import * as WebauthnJSON from "@github/webauthn-json";

function callback(url, body) {
  fetch(url, {
    method: "POST",
    body: JSON.stringify(body),
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "X-CSRF-Token": getCSRFToken(),
    },
    credentials: "same-origin",
  }).then(function (response) {
    if (response.ok) {
      window.location.replace("/");
    } else if (response.status < 500) {
      console.log(response.text());
    } else {
      console.error("Sorry, something wrong happened.");
    }
  });
}

function getCSRFToken() {
  const CSRFSelector = document.querySelector('meta[name="csrf-token"]');
  if (CSRFSelector) {
    return CSRFSelector.getAttribute("content");
  } else {
    return null;
  }
}

export default class Credential {
  static create(callbackUrl, credentialOptions) {
    WebauthnJSON.create({ publicKey: credentialOptions })
      .then(function (credential) {
        callback(callbackUrl, credential);
      })
      .catch(function (error) {
        console.error(error);
      });
    console.log("Creating new public key credential...");
  }

  static get(credentialOptions) {
    WebauthnJSON.get({ publicKey: credentialOptions })
      .then(function (credential) {
        callback("/session/callback", credential);
      })
      .catch(function (error) {
        console.error(error);
      });
    console.log("Getting public key credential...");
  }
}
