// An example of a lambda to save incoming events to S3.

// dependencies
const AWS = require('aws-sdk');

// get reference to S3 client
const s3 = new AWS.S3();
const fs = require('fs');
const { Certificate, PrivateKey } = require('@fidm/x509');

// read from terraform variables
const dstBucket = "${bucket}";

// disable to test flow
const ENABLE_VERIFICATION = true;

function deviceID(event) {
    return event["bundle"] && event["bundle"]["device"] && event["bundle"]["device"]["id"];
}

function tenantID(event) {
    return event["state"] && event["state"]["tenant"] && event["state"]["tenant"]["id"];
}

// build key. This will be the file name stored on S3.
function buildKey(deviceID_) {
    const isoDate = new Date().toISOString();
    if (deviceID_) {
        return deviceID + "_" + isoDate;
    }
    return undefined;
}

// validate certificate metadata (prevent enrolled device
// attempting to impersonate another enrolled device)

/**********************************
 * +-+ Subject: CN: Fyde Root Certificate Authority | Issuer: CN: Fyde Root Certificate Authority
  |
  +-+ Subject: CN = Fyde Intermediary Certificate Authority - Production | Issuer: CN = Fyde Root Certificate Authority
    |
    +-+ Subject: CN = fyde://<TENANT_UUID>/ | Issuer: CN = Fyde Intermediary Certificate Authority - Production
      |
      +-+ Subject: CN = "Barracuda CloudGen Access Device Certificate (<UUID>, <UUID>)" | Issuer: CN = fyde://<TENANT_UUID>/
 */
function validateEvent(deviceID_, tenantID_, certInfo) {
    if (certInfo['issuerDN'] == 'fyde://'+tenantID_+'/') {
        const ed25519Cert = Certificate.fromPEM(certInfo['clientCertPem']);
        const extn = ed25519Cert.extensions.find(extn => extn.name == 'subjectAltName');
        const altName = extn.altNames[0].dnsName;
        // X509v3 Subject Alternative Name: URI:fyde://tenantID/device-user/deviceID_
        return altName == 'URI:fyde://'+tenantID_+'/device-user/'+deviceID_;
    }
    return false;
}

exports.handler = async (event, context, callback) => {

    let body = event;
    if (event['body']) {
        body = JSON.parse(event['body']);
    } 

    const deviceID_ = deviceID(body);
    const tenantID_ = tenantID(body);
    const dstKey = buildKey(deviceID_);

    if (dstKey == undefined) {
        console.log("Bad event format.");
        return {
            statusCode: 400,
            body: "Bad event format",
        };
    }

    if (ENABLE_VERIFICATION) {
        const certInfo = event['requestContext']['authentication']['clientCert'];
        if(!validateEvent(deviceID_, tenantID_, certInfo)) {
            console.log("Unauthorized: bad certificate.");
            return {
                statusCode: 401,
                body: "Unauthorized: bad certificate.",
            };
        }
    }
    

    const payload = JSON.stringify(body);

    // debug
    console.log("Will write :\n", dstKey, "=>", payload);

    // Upload the event as a file to the destination bucket
    try {
        const destparams = {
            Bucket: dstBucket,
            Key: dstKey,
            Body: payload,
            ContentType: "text"
        };

        const putResult = await s3.putObject(destparams).promise();

        return {
            statusCode: 200,
            body: JSON.stringify(putResult),
        };

    } catch (error) {
        console.log(error);
        return {
            statusCode: 500,
            body: "Could not upload to s3",
        };
    }
};





