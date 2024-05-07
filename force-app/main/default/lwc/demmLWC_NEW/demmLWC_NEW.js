import { LightningElement, track, wire, api } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { subscribe, unsubscribe, MessageContext } from 'lightning/empApi';
import transactionController from '@salesforce/apex/CaseUpdateTriggerHandler.transactionController'
import { getRecord, getRecordUi } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class DemmLWC_NEW extends LightningElement {
    subscription = null;
    isDisplay = false
    @track displayMessage;

    @api recordId

    connectedCallback() {
        this.subscribeToPlatformEvent();
    }

    subscribeToPlatformEvent() {
        const callback = (response) => {
            const eventData = response.data.payload.openDialog__c;
            this.isDisplay = eventData
            console.log('New Platform Event Received:', eventData);
            if (eventData) {
                const result = LightningConfirm.open({
                    message: 'Change data capture events.',
                    variant: 'headerless',
                    label: 'this is the aria-label value',
                    // setting theme would have no effect
                }).then(data => {
                    if (!data) {
                        console.log('calling transactionController');
                        transactionController({ recordId: this.recordId, result: data })
                            .then((result) => {
                                // update UI
                                this.displayMessage = result;
                            })
                            .catch((error) => {
                                // handle error
                                this.displayMessage = error;
                            });
                    }
                    this.buttonAction = data;
                });
            }

        };

        subscribe('/event/demoPlatformEvent__e', -1, callback).then(response => {
            // console.log("subscribed to ", response)
            this.subscription = response;
        });
    }

    disconnectedCallback() {
        this.unsubscribeFromPlatformEvent();
    }

    unsubscribeFromPlatformEvent() {
        unsubscribe(this.subscription, response => {
            console.log('check point unsubscribe')
            this.subscription = null;
        });
    }
}