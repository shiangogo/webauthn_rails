import { Controller } from "@hotwired/stimulus";
import * as Credential from "./../credential";

export default class extends Controller {
  create(event) {
    const [data, status, xhr] = event.detail;
    console.log(data);
    const credentialOptions = data;

    if (credentialOptions["user"]) {
      const credentialNickname = event.target.querySelector("input[name='registration[nickname]']").value;
      const callbackUrl = `/registration/callback?credential_nickname=${credentialNickname}`;

      // XXX: Probably there are some problems.
      Credential.create(encodeURI(callbackUrl), credentialOptions);
    }
  }

  error(event) {
    const response = event.detail[0];
    console.error(response["error"]);
  }
}

