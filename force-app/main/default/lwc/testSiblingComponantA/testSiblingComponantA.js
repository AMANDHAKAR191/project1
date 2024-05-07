import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import testAmanLightingWebService from '@salesforce/messageChannel/testAmanLightingWebService__c'
export default class TestSiblingComponantA extends LightningElement {
    localData
    @wire(MessageContext)
        messageContext

    onValueChange(event) {
        this.localData = event.target.value
        this.dispatchEvent(new CustomEvent('datachange', { detail: this.localData }))
    }
    handleButtonClick() {
        console.log('button clicked in child');
        const payload = { userName: this.localData }
        console.log('payload: ', payload);
        // this.dispatchEvent(new CustomEvent('datachange', { userName: this.localData }))
        publish(this.messageContext, testAmanLightingWebService, payload)
    } 
}