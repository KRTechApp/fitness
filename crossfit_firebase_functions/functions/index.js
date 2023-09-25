const functions = require("firebase-functions");
const firestore = require("@google-cloud/firestore");
const firebaseStorage = require("@google-cloud/storage");
const admin = require("firebase-admin");
var serviceAccount = require("./google-service-key.json");
const axios = require('axios');

const client = new firestore.v1.FirestoreAdminClient();
// Initalize firebase
const app = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://gym---trainer-app.firebaseio.com",
});

const db = app.firestore();

// Replace BUCKET_NAME
const mainBucket = "gs://gym---trainer-app.appspot.com/";
const backUpBucket = mainBucket + "crossfit_backup";
const projectId = "gym---trainer-app";

var allBucketList = [
  "test_bucket",
  // "exercise_image",
  // "member_profile",
  // "membership_attachment",
  // "trainer_profile",
  // "workout_category",
  // "workout_category",
  // "workout_profile",
];

// const {Storage} = require('@google-cloud/storage');

// async function authenticateImplicitWithAdc() {
//   // This snippet demonstrates how to list buckets.
//   // NOTE: Replace the client created below with the client required for your application.
//   // Note that the credentials are not specified when constructing the client.
//   // The client library finds your credentials using ADC.
//   const storage = new Storage({
//     projectId,
//   });
//   const [buckets] = await storage.getBuckets();
//   console.log('Buckets:');
//   var fileList = await storage.bucket("test_bucket").getFiles();
//   for (const file of fileList) {

//     console.log(`- ${file}`);
//   }

//   console.log('Listed all storage buckets.');
// }

// authenticateImplicitWithAdc();

// const storage = new firebaseStorage.Storage();

// for (var bucketName of allBucketList) {
//   var singleBucket = admin.storage().bucket(bucketName).delete();

//   // singleBucket.deleteFiles(
//   //   {
//   //     force: true,
//   //   },
//   //   function (errors) {
//   //     // `errors`:
//   //     //    Array of errors if any occurred, otherwise null.
//   //     console.error(errors);
//   //   }
//   // );
// }

//Import database from bucket

// exports.scheduledFirestoreImport = functions.pubsub
//   .schedule("every day 00:00") //every 1 minutes
//   .onRun((context) => {
//     const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
//     const databaseName = client.databasePath(projectId, "(default)");

//     return client
//       .importDocuments({
//         name: databaseName,
//         inputUriPrefix: backUpBucket,
//         // Leave collectionIds empty to export all collections
//         // or set to a list of collection IDs to export,
//         // collectionIds: ['users', 'posts']
//         collectionIds: [],
//       })
//       .then((responses) => {
//         const response = responses[0];
//         console.log(`Operation Name: ${response["name"]}`);

//        //Delete autheticated user list

//         var userIdList = [];
//         var doNotDeleterecipientList = [
//           "admin@gmail.com",
//           "trainer@gmail.com",
//           "member@gmail.com",
//         ];

//         admin
//           .auth()
//           .listUsers()
//           .then((data) => {
//             for (var user of data.users) {
//               if (!doNotDeleterecipientList.includes(user.email)) {
//                 // userIdList.push(user.uid);
//                 // console.log(user.email);
//               }
//             }
//             console.log("userIdList : " + userIdList);

//             admin
//               .auth()
//               .deleteUsers(userIdList)
//               .then((deleteUsersResult) => {
//                 console.log(
//                   `Successfully deleted ${deleteUsersResult.successCount} users`
//                 );
//                 console.log(
//                   `Failed to delete ${deleteUsersResult.failureCount} users`
//                 );
//                 deleteUsersResult.errors.forEach((err) => {
//                   console.log(err.error.toJSON());
//                 });
//               })
//               .catch((error) => {
//                 console.log("Error deleting users:", error);
//               });
//           });
//       })
//       .catch((err) => {
//         console.error(err);
//         throw new Error("Export operation failed");
//       });
//   });

//Export database from bucket

// exports.scheduledFirestoreExport = functions.pubsub
//                                             .schedule('every 1 minutes')
//                                             .onRun((context) => {


//   const databaseName =
//     client.databasePath(projectId, '(default)');

//   return client.exportDocuments({
//     name: databaseName,
//     outputUriPrefix: backUpBucket,
//     // Leave collectionIds empty to export all collections
//     // or set to a list of collection IDs to export,
//     // collectionIds: ['users', 'posts']
//     collectionIds: []
//     })
//   .then(responses => {
//     const response = responses[0];
//     console.log(`Operation Name: ${response['name']}`);
//   })
//   .catch(err => {
//     console.error(err);
//     throw new Error('Export operation failed');
//   });
// });



//Send plan expired notification
exports.ExpiredPlanNotification = functions.pubsub
  .schedule("every day 00:00") //every 1 minutes
  .onRun((context) => {
    sendExpiredPlanNotification();
});
// sendExpiredPlanNotification();

async function sendExpiredPlanNotification() {
  const firebaseTokenList = [];
  const recipientList = [];
  var lastCreatedBy = "";
  var paymentHistoryList = [];
  var documents = (await db.collection("users").get()).docs;
  for (var doc of documents) {
    var userId = doc.id;
    var firebaseToken = doc.data()["firebase_token"];
    var email = doc.data()["email"];
    var fullName = doc.data()["full_name"];
    var currentMembership = doc.data()["current_membership"];
    var membershipTimestamp = doc.data()["membership_timestamp"];
    var createdBy = doc.data()["created_by"];

    if (firebaseToken && currentMembership == "") {
      firebaseTokenList.push(firebaseToken);
    }
    if (currentMembership == "") {
      recipientList.push({ "email": email, "name": fullName });
    }
    if (firebaseToken && currentMembership && membershipTimestamp) {
      if (createdBy != lastCreatedBy) {
        paymentHistoryList = (
          await db
            .collection("payment_history")
            .where("created_by", "==", createdBy)
            .get()
        ).docs;
      }
      console.log("userId : " + userId);
      // console.log("createdBy : " + createdBy);
      // console.log("currentMembership : " + currentMembership);
      // console.log("membershipTimestamp : " + membershipTimestamp);
      // console.log("paymentHistoryList : " + paymentHistoryList.length);
      var paymentHistoryData = paymentHistoryList.filter(
        (element) =>
          element.data()["membership_id"] == currentMembership &&
          element.data()["created_by"] == createdBy &&
          element.data()["user_id"] == userId &&
          element.data()["created_at"] == membershipTimestamp
      );

      // console.log("paymentHistoryData : " + paymentHistoryData.length);
      if (paymentHistoryData.length > 0) {
        // console.log("paymentHistoryId: " + paymentHistoryData[0].id);

        var dateGap = Math.round(
          (new Date().getTime() - membershipTimestamp) / (1000 * 60 * 60 * 24)
        );
        var extendedDays = paymentHistoryData[0].data()["extend_date"];
        var leftMemberShip =
          paymentHistoryData[0].data()["period"] + extendedDays - dateGap;
        // console.log("leftMemberShip: " + leftMemberShip);
        // console.log("extendedDays: " + extendedDays);
        // console.log("dateGap: " + dateGap);
        if (leftMemberShip < 1) {
          firebaseTokenList.push(firebaseToken);
          recipientList.push({ "email": email, "name": fullName });
        }
      } else {
        firebaseTokenList.push(firebaseToken);
        recipientList.push({ "email": email, "name": fullName });
      }
    }
  }
  // console.log(firebaseTokenList);
  if (firebaseTokenList.length > 0) {
    var bodyMap = {
      title: "Membership Expired",
      body: "Your membership plan was expired please upgrade.",
      type: "expiredMembership",
    };
  
    // Send the notification
    admin
      .messaging()
      .sendEachForMulticast({
        tokens: firebaseTokenList,
        data: bodyMap,
      })
      .then((response) => {
        if (response.failureCount > 0) {
          const successTokens = [];
          const failedTokens = [];
          response.responses.forEach((resp, idx) => {
            // console.log(resp);
            if (resp.success) {
              successTokens.push(firebaseTokenList[idx]);
            } else {
              failedTokens.push(firebaseTokenList[idx]);
            }
          });
          console.log(
            "Notification sent to the following tokens:",
            successTokens
          );
          console.log(
            "Notification could not be sent to the following tokens:",
            failedTokens
          );
        } else {
          console.log("Notification sent successfully to all devices.");
        }
      })
      .catch((error) => {
        console.error("Error sending multicast notification:", error);
      });
  }else{
    console.log("sendFirebaseNotification : Firebase token not found");
  }

  //  console.log(recipientList.length);
   if (recipientList.length > 0) {
    var subject = 'Membership plan has expired';
    var plainText = 'Hello Your Membership plan has expired. Please renew your membership to continue enjoying our services. Thanks & Regards';
    var htmlText = '<p>Hello</br></br> &emsp; Your Membership plan has expired. Please renew your membership to continue enjoying our services.</br></br>Thanks & Regards</p>';
      
      sendEmailNotification(recipientList,subject,plainText,htmlText);

   }else{
    console.log("sendEmailNotification : Email not found");
  }
  
}

async function sendEmailNotification(recipientList,subject,plainText,htmlText) {

  var documents = (await db.collection("admin_setting").get()).docs;

  if(documents.length > 0 && documents[0].data().hasOwnProperty("email_from") &&
  documents[0].data().hasOwnProperty("email_name") &&
  documents[0].data().hasOwnProperty("sendinblue_api_key")){

    var doc = documents[0].data();

    var emailFrom = doc["email_from"];
    var emailName = doc["email_name"];
    var API_KEY = doc["sendinblue_api_key"];

    const API_URL = 'https://api.sendinblue.com/v3/smtp/email';
  
    
    const data = {
      sender: { email: emailFrom, name: emailName },
      to: recipientList,
      subject: subject,
      textContent: plainText,
      htmlContent: htmlText,
    };
  
    try {
      const response = await axios.post(API_URL, data, {
        headers: {
          'api-key': API_KEY,
          'content-type': 'application/json',
        },
      });
  
      console.log('Email sent successfully:', response.data);
    } catch (error) {
      console.error('Error sending email:', error.response.data);
    }
  }else{
    console.error('sendEmailNotification: data missing email_name, email_from, sendinblue_api_key');
  }


  
}


