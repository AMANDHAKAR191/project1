import { LightningElement, api, track, wire } from 'lwc';
import getPicklistValues from '@salesforce/apex/CustomizablePath.getPicklistValues';
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CustomizablePath extends LightningElement {
  @track rawPicklistValues = [];
  @api objectApiName;
  @api pickListApiName;
  @api recordId;
  @api fields;
  currentRecord;
  currentPicklistItemValue;

  @wire(getPicklistValues, {
    objectApiName: "$objectApiName",
    pickListApiName: "$pickListApiName"
  })
  picklistData;

  get fieldsArray() {
    return this.pickListApiName
      ? this.pickListApiName
          .split(",")
          .map((field) => `${this.objectApiName}.${field}`)
      : [];
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: "$fieldsArray"
  })
  getCurrentRecord({ error, data }) {
    console.log("getCurrentRecord check", this.rawPicklistValues);
    console.log("getCurrentRecord data", data);
    console.log("getCurrentRecord error", error);
    if (data) {
      console.log("Record data:", data);
      this.currentRecord = data;
      console.log("current record1: ", this.currentRecord);
    } else {
      console.error("Error fetching record:", error);
    }
  }

  connectedCallback() {
    console.log("Picklist API Name:", this.pickListApiName);
    console.log("recordId:", this.recordId);
    // console.log("current record: ", this.currentRecord);
    // console.log("getFieldValue: ",getFieldValue(this.currentRecord, this.pickListApiName));

    if (!this.pickListApiName) {
      console.error("pickListApiName is not set.");
    }
  }

  get fieldName() {
    return this.pickListApiName ? [this.pickListApiName] : [];
  }

  get labels() {
    console.log(
      "this.rawPicklistValues: ",
      this.rawPicklistValues.length === 0
    );
    if (this.rawPicklistValues.length === 0) {
      // console.log("this.rawPicklistValues: empty");
      this.rawPicklistValues = this.picklistData.data
        ? this.picklistData.data.map((item, index) => ({
            key: index,
            label: item.label,
            color: item.color,
            picklistValue: item.picklistValue,
            class: "slds-path__item slds-is-incomplete", // default class
            completed: false,
            displayLabel:
              item.label.length > 10
                ? item.label.substring(0, 10) + "..."
                : item.label
          }))
        : [];
    }
    return this.rawPicklistValues;
  }

  getColorByLabel(label) {
    if (this.picklistData.data) {
      const item = this.picklistData.data.find((i) => i.label === label);
      return item ? item.color : "No color found";
    }
    return "No data available";
  }

  getSvgUrl(index) {
    if (index === 0) {
      return this.startSvg;
    }
    if (index === this.labels.length - 1) {
      return this.endSvg;
    }
    return this.middleSvg;
  }

  handleStageClick(event) {
    console.log("handleStageClick: ", event.currentTarget.dataset.index);
    this.displayPath(event.currentTarget.dataset.index);
  }

  displayPath(index) {
    console.log("handleStageClick: ", index);
    const currentItemIndex = parseInt(index, 10);
    const priviousItemIndex = parseInt(index, 10) - 1;
    console.log("currentItemIndex: ", currentItemIndex);
    this.currentPicklistItemValue =
      this.rawPicklistValues[currentItemIndex].picklistValue;
    console.log(
      "currentPicklistItemValue: ",
      JSON.stringify(this.currentPicklistItemValue)
    );
    this.rawPicklistValues.forEach((item, idx) => {
      // console.log("idx<=index: ", idx <= priviousItemIndex);
      item.completed = idx <= priviousItemIndex;
      // item.class = item.completed
      //   ? "shape shape-inactive"
      //   : "shape shape-inactive";
      // console.log("item.color: ", item.color);
      item.style = item.completed
        ? "background-color: #" + item.color + ";"
        : "";
      // console.log("idx", idx);
      // console.log("item.class: ", item.class);
    });
  }
  onUpdate(event) {
    const fields = {};
    fields["Id"] = this.recordId;
    fields[this.pickListApiName] = this.currentPicklistItemValue;
    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Contact updated",
            variant: "success"
          })
        );
        // Display fresh data in the form
        // return refreshApex(this.contact);
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error creating record",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }
}