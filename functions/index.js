const functions = require("firebase-functions");
const admin = require('firebase-admin');

admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateFollowers = functions.firestore.documents("/followers/{userId}/userFollowers/{followerId}")
            .onCreate(async (snapshot,context)=>{
            const userId = context.params.userId;
            const followerId = context.params.followerId;


            const followedUserRef= admin.firestore().collection('posts')
                                            .doc(userId)
                                            .collection('userPosts');

            const timelinePostRef = admin.firestore().collection('timeline')
                                                     .doc(followerId)
                                                     .collection('timelinePosts');

            const querySnapshot =  await followedUserRef.get();

            querySnapshot.forEach(doc=>{
                if(doc.exists){
                    const postId = doc.id;
                    const postData = doc.data();
                    timelinePostRef.doc(postId).set(postData);

                }

            })

            } );