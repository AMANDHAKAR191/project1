import { LightningElement, track, wire, api } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { subscribe, unsubscribe, MessageContext } from 'lightning/empApi';
import revertRecordUpdate from '@salesforce/apex/ObjectUpdateHandler.revertRecordUpdate'
import getCustomSetting from '@salesforce/apex/ObjectUpdateHandler.getCustomSetting';
import setCustomSetting from '@salesforce/apex/ObjectUpdateHandler.setCustomSetting';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent, registerRefreshHandler, unregisterRefreshHandler } from 'lightning/refresh';
import Toast from 'lightning/toast';

export default class DemoLWCNew extends LightningElement {
    subscription = null;
    isDisplay = false
    callOrigin = 'com/salesforce/api/soap/60.0;client=SfdcInternalAPI/'

    @track displayMessage;
    @api recordId
    @api objectApiName;
    objectEventName
    isLoading = false
    refreshHandlerID;

    connectedCallback() {
        this.objectEventName = generateEventName(this.objectApiName)
        this.subscribeToPlatformEvent();
        
        this.isLoading = true
        setCustomSetting({ is_Active: false }).then(_ => {
            console.log('setting isRunningFirstTime false');
            this.isLoading = false
        }).catch(error => {
            this.isLoading = false
        })
    }

    disconnectedCallback() {
        this.unsubscribeFromPlatformEvent();
    }
    subscribeToPlatformEvent() {
        const callback = (response) => {
            this.isLoading = true
            console.log('New Change data capture Event Received:', response);
            const changeType = response.data.payload.ChangeEventHeader.changeType
            const originName = response.data.payload.ChangeEventHeader.changeOrigin
            if (changeType == 'UPDATE' && this.callOrigin == originName) {
                getCustomSetting().then(isRunningFirstTime => {
                    console.log('isRunningFirstTime: ', isRunningFirstTime);
                    //this code block is to stop running this code revert operation again and again because we will
                    // another enother event after completing revert operation.
                    if (isRunningFirstTime) {
                        // update isRunningFirstTime false
                        setCustomSetting({ is_Active: false }).then(_ => {
                            this.isLoading = false
                        }).catch(error => {
                            this.isLoading = false
                        })
                        
                    } else {
                        const eventData = response.data.payload.ChangeEventHeader.recordIds
                        let changedFields = response.data.payload.ChangeEventHeader.changedFields
                        if (eventData) {
                            this.isLoading = false
                            this.openDialog(changedFields)
                        }                
                    }
                })
            } else {
                //when reocrd are updated from apex
                this.isLoading = false
                Toast.show({
                    label: 'Record Updates',
                    message: 'records are being updated from backend',
                    mode: 'sticky',
                    variant: 'info'
                }, this)
                this.dispatchEvent(new RefreshEvent())
            }
        };
        subscribe(generateEventName(this.objectApiName), -1, callback).then(response => {
            console.log("subscribed to ", response)
            this.subscription = response;
        });
    }

    unsubscribeFromPlatformEvent() {
        unsubscribe(this.subscription, response => {
            console.log('check point unsubscribe')
            this.subscription = null;
        });
    }

    openDialog(changedFields) {
        LightningConfirm.open({
            message: 'Change data capture events.',
            variant: 'headerless',
            label: 'this is the aria-label value',
            // setting theme would have no effect
        }).then(data => {
            if (!data) {
                this.isLoading = true
                setCustomSetting({ is_Active: true }).then(_ => {
                    getCustomSetting().then(value => {
                        console.log('value: ', value)
                        if (value) {
                            console.log('calling revertRecordUpdate')
                            revertRecordUpdate({ recordId: this.recordId, result: data, objectApiName: this.objectApiName, changedFields: changedFields })
                                .then((result) => {
                                    // update UI
                                    this.displayMessage = result;
                                    this.isLoading = false
                                    Toast.show({
                                        label: 'Record Updated',
                                        message: 'record update is reverted',
                                        mode: 'sticky',
                                        variant: 'success'
                                    }, this)
                                    this.dispatchEvent(new RefreshEvent())
                                })
                                .catch((error) => {
                                    // handle error
                                    this.displayMessage = error;
                                    this.isLoading = false
                                });
                        } else {
                            this.isLoading = false
                        }
                    })
                }).catch(error => {
                    console.log('error while setting isRunningFirstTime true: ', error)
                })
            }
            this.buttonAction = data;
        });
    }


    

}
function generateEventName(objectApiName) {
    // console.log('objectApiName: ', objectApiName)
    // Remove '__c' from the objectApiName and append '__ChangeEvent' to generate the event name
    let eventName
    if (objectApiName.endsWith('__c')) {
        eventName = `/data/${objectApiName.replace('__c', '__ChangeEvent')}`;
    } else {
        eventName = `/data/${objectApiName}ChangeEvent`;
    }
    return eventName;
}