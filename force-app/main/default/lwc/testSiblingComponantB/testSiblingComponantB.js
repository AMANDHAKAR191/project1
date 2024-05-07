import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import testAmanLightingWebService from '@salesforce/messageChannel/testAmanLightingWebService__c'

export default class TestSiblingComponantB extends LightningElement {
    @api shareddata
    userName
    subscription = null;
    @wire(MessageContext)
    messageContext
    connectedCallback() {
        this.subscription = subscribe(this.messageContext, testAmanLightingWebService, (value) => this.handleUserName(value))

    }
    handleUserName(value) {
        console.log('userName: ', value.userName);
        this.userName = value.userName
    }
    disconnectedCallback() {
        unsubscribe(this.subscription)
    }
}