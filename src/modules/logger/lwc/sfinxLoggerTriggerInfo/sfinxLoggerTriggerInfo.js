import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

const FIELDS = [
    'Log__c.Trigger_Operation__c',
    'Log__c.Trigger_Size__c'
];


export default class SfinxLoggerTriggerInfo extends LightningElement {

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS }) logRecord;

    get operation() {
        return getFieldValue(this.logRecord.data, TRIGGER_OPERATION);
    }

    get triggerSize() {
        return getFieldValue(this.logRecord.data, TRIGGER_SIZE);
    }
}
