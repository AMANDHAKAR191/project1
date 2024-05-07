import { LightningElement, track, wire } from 'lwc';
import getContactAll from '@salesforce/apex/testComponantApexClass.getContactAll';
import updateContacts from '@salesforce/apex/testComponantApexClass.updateContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerRefreshHandler, unregisterRefreshHandler, RefreshEvent } from 'lightning/refresh';
import NAME_FIELD from '@salesforce/schema/Customer_New__c.Name';

const columns = [
    { label: 'Id', fieldName: 'Id', type: 'Id' },
    { label: 'Last Name', fieldName: 'LastName', editable: true },
    { label: 'First Name', fieldName: 'FirstName', editable: true }
];

export default class CookieConsentToggleButton extends LightningElement {
    nameField = NAME_FIELD;
    columns = columns;
    @track contactList;
    // refreshHandlerId;

    connectedCallback() {
        // this.refreshHandlerId = registerRefreshHandler(this, this.refreshHandler);
        this.loadContacts();
    }

    disconnectedCallback() {
        // unregisterRefreshHandler(this.refreshHandlerId);
    }
    // refreshHandler() {
    //     console.log('refreshHandler')
    //     return new Promise(resolve => {
    //         this.loadContacts()
    //         resolve(true)
    //     })
    // }

    loadContacts() {
        console.log('loadContacts')
        getContactAll()
            .then(result => {
                this.contactList = result;
                console.log('data:', result);
            })
            .catch(error => {
                console.error('Error:', error);
                this.showErrorToast('Error loading contacts', error.body.message);
            });
    }

    handleCellChange(event) {
        const draftValues = event.detail.draftValues;
        console.log('draft values:', draftValues);
        updateContacts({ contacts: draftValues })
            .then(result => {
                // this.template.querySelector('lightning-datatable').draftValues = [];
                // this.loadContacts()
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contacts updated',
                        variant: 'success'
                    })
                );
                // // Clear all draft values
                // this.template.querySelector('lightning-datatable').draftValues = [];
                // this.dispatchEvent(new RefreshEvent())
                // this.loadContacts()
            })
            .catch(error => {
                console.error('Error updating records:', error);
                this.showErrorToast('Error updating records', error.body.message);
            });
    }

    showErrorToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'error'
            })
        );
    }
}