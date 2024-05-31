import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import DEBUG_DATA_FIELD from '@salesforce/schema/Log__c.Debug_Data__c';

export default class sfinxLoggerDebugData extends LightningElement {

    @api recordId;
    debugData;

    fields = [DEBUG_DATA_FIELD];

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        if (data) {
            this.debugData = data.fields.Debug_Data__c.value;
        } else {
            this.debugData = undefined;
        }
    }

    renderedCallback() {
        if (this.debugData) {
            const preElement = this.template.querySelector('pre');
            if (preElement) {
                preElement.innerHTML = this.syntaxHighlight(this.debugData);
            }
        }
    }

    syntaxHighlight(json) {

        try {
            json = JSON.stringify(JSON.parse(json), null, 2)
                .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
                .replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?)|(\b(true|false|null)\b)|(-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, match => {
                    let cls = 'number';
                    if (/^"/.test(match)) {
                        cls = /:$/.test(match) ? 'slds-text-color_destructive' : 'slds-text-color_success';
                    } else if (/true|false/.test(match)) {
                        cls = 'boolean';
                    } else if (/null/.test(match)) {
                        cls = 'null';
                    }
                    return `<span class="${cls}">${match}</span>`;
                });
        } catch (e) {
            json = parsePartialJSON(json);
        }

        // Replacing SF IDs with links
        return json.replace(/(["\/])([a-zA-Z0-9]{18})"/g, (match, p1, p2) => {
            return `${p1}<a href="/${p2}" target="_blank">${p2}</a>"`;
        });
    }

    parsePartialJSON(json) {
        let depth = 0;
        let partialJson = '';
        let lastChar = '';

        for (let char of json) {
            partialJson += char;

            if (char === '{' || char === '[') {
                depth++;
            } else if (char === '}' || char === ']') {
                depth--;
                if (depth === 0) {
                    try {
                        return JSON.parse(partialJson);
                    } catch (e) {
                        // Continue to add characters to partialJson
                    }
                }
            }

            lastChar = char;
        }

        // Attempt to close the JSON structure if it's not deeply nested
        while (depth > 0) {
            if (lastChar === '{') {
                partialJson += '}';
            } else if (lastChar === '[') {
                partialJson += ']';
            }
            depth--;
        }

        try {
            return JSON.parse(partialJson);
        } catch (e) {
            // Return the best effort parse
            return {};
        }
    }
}
