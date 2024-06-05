import { LightningElement, track, wire } from 'lwc';
import CreateOpportunity from '@salesforce/apex/OpportunityRecordHandler.CreateOpportunity';
import getAllOpportunities from '@salesforce/apex/OpportunityRecordHandler.getAllOpportunities';
import LightningAlert from 'lightning/alert';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import CREATED_DATE_FIELD from '@salesforce/schema/Opportunity.CreatedDate';
import OBJECT_NAME from '@salesforce/schema/Opportunity'
import { getRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';

const columns = [
    { label: 'Id', fieldName: 'Id', type: 'Id' },
    { label: 'Name', fieldName: 'Name', editable: true },
    { label: 'Created date', fieldName: 'CreatedDate', editable: true }
];

export default class OpportunityRecordLWC extends LightningElement {
    objectApiName = OBJECT_NAME
    columns = columns;
    formValues = {}
    isLoading = false
    error
    stageOptions = [
        { label: 'Prospecting', value: 'Prospecting' },
        { label: 'Qualification', value: 'Qualification' },
        { label: 'Needs Analysis', value: 'Needs Analysis' },
        { label: 'Value Proposition', value: 'Value Proposition' },
        { label: 'Id. Decision Makers', value: 'Id. Decision Makers' },
        { label: 'Perception Analysis', value: 'Perception Analysis' },
        { label: 'Proposal/Price Quote', value: 'Proposal/Price Quote' },
        { label: 'Negotiation/Review', value: 'Negotiation/Review' },
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' }
    ];
    apiResult
    @track opportunityRecords

    // @wire(getAllOpportunities, {})
    // wiredRecord({ error, data }) {
    //     if (error) {
            
    //     }
    //     if (data) {
            
    //     }
    // }

    handleCellChange(event) {
        console.log('Cell Change event: ',event);
    }
    

    handleValueChange(event) {
        // const field = event.target.label.toLowerCase
        // const value = event.detail.value
        console.log('event: ',event);
        const name = event.target.name
        const value = event.detail.value
        console.log('name: ',name);
        console.log('value: ',value);
        if (name == 'closeDate') {
            const date = new Date(value)
            const formattedDate = date.toLocaleDateString('en-GB')
            console.log('formattedDate: ',formattedDate);
            this.formValues = { ...this.formValues, [name]: formattedDate }
        } else {
            this.formValues = { ...this.formValues, [name]: value }
        }
    }

    submit() {
        this.isLoading = true;
        console.log('formData: ', this.formValues.name);
        CreateOpportunity({name:this.formValues.name, stageName:this.formValues.stageName, closeDate:this.formValues.closeDate})
            .then((result) => {
                console.log('result: ', result);
                const jsonObj = JSON.parse(result);
                console.log('status: ', jsonObj.status);
                if (!jsonObj.status) {
                    this.isLoading = false;
                    this.error = jsonObj.ERROR
                    LightningAlert.open({
                        message: jsonObj.ERROR,
                        theme: 'error', // a red theme intended for error states
                        label: 'Error!', // this is the header text
                    });
                } else {
                    this.apiResult = jsonObj.Id
                    this.isLoading = false;
                    getAllOpportunities({ oppId: jsonObj.Id })
                        .then((date) => {
                            console.log('data: ', data);
                            this.opportunityRecords = data
                            console.log('this.opportunityRecords: ', this.opportunityRecords);
                        }).catch((error) => {
                            console.log('error: ', error);
                    })
                    this.dispatchEvent(new RefreshEvent())
                }
            })
            .catch((error) => {
                console.log('error: ', error);
                this.apiResult = error
                this.isLoading = false;
            });
    }
}