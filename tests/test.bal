//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

package tests;

import ballerina/io;
import ballerina/net.http;
import ballerina/time;
import salesforce;

string url = "your_url";
string accessToken = "your_access_token";
string clientId = "your_client_id";
string clientSecret = "your_client_secret";
string refreshToken = "your_refresh_token";
string refreshTokenEndpoint = "your_refresh_token_endpoint";
string refreshTokenPath = "your_refresh_token_path";

public function main (string[] args) {
    endpoint salesforce:SalesforceEndpoint salesforceConnector {
        oauth2Config:{
                         accessToken:accessToken,
                         baseUrl:url,
                         clientId:clientId,
                         clientSecret:clientSecret,
                         refreshToken:refreshToken,
                         refreshTokenEP:refreshTokenEndpoint,
                         refreshTokenPath:refreshTokenPath,
                         clientConfig:{}
                     }
    };

    error Error = {};
    json jsonResponse;
    string nextUrl;

    string apiVersion = "v37.0";
    string sampleSObjectAccount = "Account";
    string sampleSObjectLead = "Lead";
    string sampleSObjectProduct = "Product";
    string sampleSObjectContact = "Contact";
    string sampleSObjectOpportunity = "Opportunity";
    string sampleCustomObject = "Support_Account";

    json account = {Name:"ABC Inc", BillingCity:"New York", Global_POD__c:"UK"};
    json supportAccount = {DevelopmentSupportHours:"72"};
    json lead = {LastName:"Carmen", Company:"WSO2", City:"New York"};
    json contact = {LastName:"Patson"};
    json createOpportunity = {Name:"DevServices", StageName:"30 - Proposal/Price Quote", CloseDate:"2019-01-01"};
    json product = {Name:"APIM", Description:"APIM product"};
    string searchString = "FIND {John Keells Holdings PLC}";
    string accountId = "";
    string leadId = "";
    string contactId = "";
    string opportunityId = "006L0000008xmcU";
    string productId = "";
    string queryString = "SELECT name FROM Account";
    time:Time now = time:currentTime();
    string endDateTime = now.format("yyyy-MM-dd'T'HH:mm:ssZ");
    time:Time weekAgo = now.subtractDuration(0, 0, 7, 0, 0, 0, 0);
    string startDateTime = weekAgo.format("yyyy-MM-dd'T'HH:mm:ssZ");

    json|salesforce:SalesforceConnectorError response;
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////

    io:println("\n------------------------MAIN METHOD: getAvailableApiVersions()----------------------");
    response = salesforceConnector -> getAvailableApiVersions();
    checkErrors(response);

    io:println("\n------------------------MAIN METHOD: getResourcesByApiVersion()----------------------");
    response = salesforceConnector -> getResourcesByApiVersion(apiVersion);
    checkErrors(response);

    io:println("\n------------------------MAIN METHOD: getOrganizationLimits ()----------------------");
    response = salesforceConnector -> getOrganizationLimits();
    checkErrors(response);

    //======================================== Query ===============================================//

    io:println("\n--------------------------MAIN METHOD: getQueryResult ()-------------------------");
    response = salesforceConnector -> getQueryResult("SELECT name FROM Account");
    checkErrors(response);

    io:println("\n----------------------MAIN METHOD: explainQueryOrReportOrListview ()---------------------");
    response = salesforceConnector -> explainQueryOrReportOrListview(queryString);
    checkErrors(response);

    //======================================= Search ==============================================//

    io:println("\n------------------------MAIN METHOD: Executing SOSl Searches ------------------");
    response = salesforceConnector -> searchSOSLString(searchString);
    checkErrors(response);


    // ============================ Describe SObjects available and their fields/metadata ===================== //

    io:println("\n-----------------------MAIN METHOD: getSObjectBasicInfo() --------------------------");
    response = salesforceConnector -> getSObjectBasicInfo(sampleSObjectAccount);
    checkErrors(response);

    io:println("\n-----------------------MAIN METHOD: describeAvailableObjects() ---------------------------");
    checkErrors(response);

    io:println("\n-----------------------MAIN METHOD: describeSObject() ---------------------------");
    response = salesforceConnector -> describeSObject(sampleSObjectAccount);
    checkErrors(response);

    io:println("\n-----------------------MAIN METHOD: sObjectPlatformAction() ---------------------------");
    response = salesforceConnector -> sObjectPlatformAction();
    checkErrors(response);

    io:println("\n-----------------------MAIN METHOD: getDeletedRecords() ---------------------------");
    response = salesforceConnector -> getDeletedRecords(sampleSObjectAccount, startDateTime, endDateTime);
    checkErrors(response);

    io:println("\n-----------------------MAIN METHOD: getUpdatedRecords() ---------------------------");
    response = salesforceConnector -> getUpdatedRecords(sampleSObjectAccount, startDateTime, endDateTime);
    checkErrors(response);


    // ============================ ACCOUNT SObject: get, create, update, delete ===================== //

    io:println("\n------------------------ACCOUNT SObjecct Information----------------");
    string|salesforce:SalesforceConnectorError stringAccount = salesforceConnector -> createAccount(account);
    match stringAccount {
        string id => {
            io:println("Account created with: " + id);
            accountId = id;
        }
        salesforce:SalesforceConnectorError err => {
            io:println("Error ocurred");
        }
    }

    io:println("\nReceived account details: ");
    response = salesforceConnector -> getAccountById(accountId);
    checkErrors(response);

    io:println("\nUpdated account: ");
    response = salesforceConnector -> updateAccount(accountId, account);
    checkErrors(response);

    io:println("\nDeleted account: ");
    response = salesforceConnector -> deleteAccount(accountId);
    checkErrors(response);



    // ============================ LEAD SObject: get, create, update, delete ===================== //

    io:println("\n------------------------LEAD SObjecct Information----------------");
    string|salesforce:SalesforceConnectorError stringLead = salesforceConnector -> createLead(lead);
    match stringLead {
        string id => {
            io:println("Lead created with: " + id);
            leadId = id;
        }
        salesforce:SalesforceConnectorError err => {
            io:println("Error ocurred");
        }
    }

    io:println("\nReceived Lead details: ");
    response = salesforceConnector -> getLeadById(leadId);
    checkErrors(response);

    io:println("\nUpdated Lead: ");
    response = salesforceConnector -> updateLead(leadId, lead);
    checkErrors(response);

    io:println("\nDeleted Lead: ");
    response = salesforceConnector -> deleteLead(leadId);
    checkErrors(response);



    // ============================ CONTACTS SObject: get, create, update, delete ===================== //

    io:println("\n------------------------CONTACT SObjecct Information----------------");
    string|salesforce:SalesforceConnectorError stringContact = salesforceConnector -> createContact(contact);
    match stringContact {
        string id => {
            io:println("Contact created with: " + id);
            contactId = id;
        }
        salesforce:SalesforceConnectorError err => {
            io:println("Error ocurred");
        }
    }

    io:println("\nReceived Contact details: ");
    response = salesforceConnector -> getContactById(contactId);
    checkErrors(response);

    io:println("\nUpdated Contact: ");
    response = salesforceConnector -> updateContact(contactId, contact);
    checkErrors(response);

    io:println("\nDeleted Contact: ");
    response = salesforceConnector -> deleteContact(contactId);
    checkErrors(response);


    // ============================ PRODUCTS SObject: get, create, update, delete ===================== //

    io:println("\n------------------------PRODUCTS SObjecct Information----------------");
    string|salesforce:SalesforceConnectorError stringProduct = salesforceConnector -> createProduct(product);
    match stringProduct {
        string id => {
            io:println("Products created with: " + id);
            productId = id;
        }
        salesforce:SalesforceConnectorError err => {
            io:println("Error ocurred");
        }
    }

    io:println("\nReceived Product details: ");
    response = salesforceConnector -> getProductById(productId);
    checkErrors(response);

    io:println("\nUpdated Product: ");
    response = salesforceConnector -> updateProduct(productId, product);
    checkErrors(response);

    io:println("\nDeleted Product: ");
    response = salesforceConnector -> deleteProduct(productId);
    checkErrors(response);


    // ============================ OPPORTUNITY SObject: get, create, update, delete ===================== //

    //io:println("\n------------------------OPPORTUNITY SObjecct Information----------------");
    //string|salesforce:SalesforceConnectorError stringResponse = salesforceConnector.createOpportunity(createOpportunity);
    //match stringResponse {
    //    string id => {
    //        io:println("Account created with: " + id);
    //        opportunityId = id;
    //    }
    //    salesforce:SalesforceConnectorError err => {
    //        io:println("Error ocurred");
    //    }
    //}
    //
    //io:println("\nReceived Opportunity details: ");
    //response = salesforceConnector.getOpportunityById(opportunityId);
    //checkErrors(response);
    //
    //io:println("\nUpdated Opportunity: ");
    //response = salesforceConnector.updateOpportunity(opportunityId, createOpportunity);
    //checkErrors(response);
    //
    //io:println("\nDeleted Opportunity: ");
    //response = salesforceConnector.deleteOpportunity(opportunityId);
    //checkErrors(response);
}


public function checkErrors (json|salesforce:SalesforceConnectorError receivedResponse) {
    match receivedResponse {
        json payload => {
        //io:println(payload);
            io:println("Success!");
        }
        salesforce:SalesforceConnectorError err => {
            io:println(err);
        }
    }
}
