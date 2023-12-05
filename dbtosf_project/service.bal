import ballerina/http;
import ballerinax/salesforce;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for transforming a contact record in salesforce
    # + salesforceContact - the input contacts
    # + return - transformed contacts or error
    resource function post contact(@http:Payload SalesforceContact salesforceContact) returns Contact|error? {
        Contact contact = transform(salesforceContact);
        return contact;
    }

    resource function get search(string email) returns Contact[]|error? {

        salesforce:Client salesforceEp = check new (config = {
            baseUrl: baseUrl,
            auth: {
                refreshUrl: refreshUrl,
                refreshToken: refreshToken,
                clientId: clientId,
                clientSecret: clientSecret
            }
        });

        stream<SalesforceContact, error?> queryResponse = check salesforceEp->query(soql = string `SELECT Id,FirstName,LastName,Email,Phone FROM Contact WHERE (Email = '${email}')`);
    
        Contact[] contacts = [];

        check queryResponse.forEach(function (SalesforceContact sfContact) {
            contacts.push(transform(sfContact));
        });
        
        return contacts;
    }
}

type SalesforceContact record {
    record {
        string 'type;
        string url;
    } attributes;
    string Id;
    string FirstName;
    string LastName;
    string Email;
    string Phone;
};

type Contact record {
    string fullName;
    string phoneNumber;
    string email;
    string id;
};

function transform(SalesforceContact salesforceContact) returns Contact => {
    id: salesforceContact.Id,
    fullName: salesforceContact.FirstName + salesforceContact.LastName,
    email: salesforceContact.Email,
    phoneNumber: salesforceContact.Phone
};

salesforce:Client salesforceEp = check new (config = {
    baseUrl: baseUrl,
    auth: {
        refreshUrl: refreshUrl,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
});


configurable string baseUrl = ?;
configurable string refreshUrl = ?;
configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

