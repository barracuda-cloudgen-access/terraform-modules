// just an example again
// dependencies
const AWS = require('aws-sdk');

// get reference to S3 client
const s3 = new AWS.S3();

const dstBucket = "${bucket}";

// build key. This will be the file name stored on S3.
function buildKey(event) {
    const isoDate = new Date().toISOString();
    const deviceId = event["bundle"] && event["bundle"]["device"] && event["bundle"]["device"]["id"];
    if (deviceId) {
        return deviceId + "_" + isoDate;
    }
    return undefined;
}

exports.handler = async (event, context, callback) => {

    console.log("Event:", event);

    let baseEvent = event;
    if (event['body']) {
        baseEvent = JSON.parse(event['body']);
    } 

    console.log("Event:", baseEvent);
    
    const dstKey = buildKey(baseEvent);
    if (dstKey == undefined) {
        console.log("BAD EVENT FORMAT!!!!");
        return {
            statusCode: 500,
            body: "Bad event format",
        };
    }

    const body = JSON.stringify(baseEvent);

    // debug
    console.log("Will write :\n", dstKey, "=>", body);

    // Upload the event as a file to the destination bucket
    try {
        const destparams = {
            Bucket: dstBucket,
            Key: dstKey,
            Body: body,
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


