import { LightningElement } from 'lwc';

export default class TestParentComponant extends LightningElement {
    sharedData;

    handleDataChange(event) {
        this.sharedData = event.detail;
    }
}