import { LightningElement, api, wire } from "lwc";
import { gql, graphql, refreshGraphQL } from 'lightning/uiGraphQLApi';
import { getRecord } from "lightning/uiRecordApi";

const REQUEST_ID_FIELD = "Log__c.Request_Id__c";

export default class SfinxLoggerRelatedLogs extends LightningElement {

    @api recordId;
    @api requestId;

    logs = [];

    // Fetch the Request_Id__c field for the current record
    @wire(getRecord, { recordId: "$recordId", fields: [REQUEST_ID_FIELD] })
    handleRecord({ error, data }) {
        if (data) {
            this.requestId = data.fields.Request_Id__c.value;
        } else if (error) {
            this.logError("Error fetching Request_Id__c", error);
        }
    }

    // GraphQL query for fetching related logs
    @wire(graphql, {
        query: gql`
            query getRelatedLogs($recordId: ID!, $requestId: String!, $limit: Int = 10) {
                uiapi {
                    query {
                        Log__c(
                            where: {
                                Id: { ne: $recordId },
                                Request_Id__c: { eq: $requestId }
                            }
                            first: $limit
                            orderBy: { 
                                Log_Time__c: { order: ASC } 
                            }
                        ) {
                            edges {
                                node {
                                    Id
                                    Name { value }
                                    Log_Time__c { value }
                                    Level__c { label }
                                    Message__c { value }
                                }
                            }
                        }
                    }
                }
            }
        `,
        variables: "$queryParams"
    })
    handleGraphQLQuery({ data, errors }) {
        if (data) {
            this.logs = this.mapLogs(data.uiapi.query.Log__c.edges);
        } else if (errors) {
            this.logError("GraphQL query errors", errors);
        }
    }

    get queryParams() {
        return {
            recordId: this.recordId,
            requestId: this.requestId
        }
    }

    mapLogs(edges) {
        return edges.map(edge => ({
            id: edge.node.Id,
            name: edge.node.Name.value,
            logTime: edge.node.Log_Time__c.value,
            level: edge.node.Level__c.label,
            message: edge.node.Message__c.value,
            link: "/" + edge.node.Id
        }));
    }

    logError(message, error) {
        console.error(`SFINX LOGGER: ${message}`, error);
    }

    async refresh() {
        return refreshGraphQL(this.logs);
    }
}