import { LightningElement, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.FirstName";
import USER_ACCOUNT from "@salesforce/schema/User.Contact.Account.Name";

export default class LevelZeroDashboard extends LightningElement {
  progressPercent = "50";
  message =
    "Your profile is " +
    this.progressPercent +
    " % complete , please complete your profile";
  showUploadModal = false;

  @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, USER_ACCOUNT] })
  userData;

  get userFirstName() {
    return getFieldValue(this.userData.data, NAME_FIELD);
  }

  get userAccountName() {
    return getFieldValue(this.userData.data, USER_ACCOUNT);
  }

  get acceptedFormats() {
    return [".png", ".jpg", ".jpeg"];
  }

  handleAvatarClick() {
    this.showUploadModal = true;
  }

  openModal() {
    this.showUploadModal = true;
  }

  closeModal() {
    this.showUploadModal = false;
  }
}
