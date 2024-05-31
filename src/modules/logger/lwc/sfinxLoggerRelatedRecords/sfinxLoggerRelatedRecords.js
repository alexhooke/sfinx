import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import RELATED_RECORDS_FIELD from '@salesforce/schema/Log__c.Related_Records__c';

export default class sfinxLoggerRelatedRecords extends LightningElement {

    @api recordId;

    relatedRecords;
    error;

    fields = [RELATED_RECORDS_FIELD];

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        if (data) {
            this.relatedRecords = data.fields.Related_Records__c.value;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.relatedRecords = undefined;
        }
    }

    renderedCallback() {
        if (this.relatedRecords) {
            this.highlightJson();
        }
    }

    highlightJson() {
        const preElement = this.template.querySelector('pre');
        if (preElement) {
            preElement.innerHTML = this.syntaxHighlight(this.relatedRecords);
        }
    }

    syntaxHighlight(json) {

        json = JSON.stringify(JSON.parse(json), null, 2);
        json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

        json = json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?)|(\b(true|false|null)\b)|(-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
            let cls = 'number';
            if (/^"/.test(match)) {
                if (/:$/.test(match)) {
                    cls = 'slds-text-color_destructive'; // key
                } else {
                    cls = 'slds-text-color_success'; // string
                }
            } else if (/true|false/.test(match)) {
                cls = 'boolean';
            } else if (/null/.test(match)) {
                cls = 'null';
            }
            return `<span class="${cls}">${match}</span>`;
        });

        // Making SF ID as links
        return json.replace(/(["\/])([a-zA-Z0-9]{18})"/g, function(match, p1, p2) {
            const url = '/' + p2;
            return `${p1}<a href="${url}" target="_blank">${p2}</a>"`;
        });
    }

}
