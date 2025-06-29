import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> sendConnectionRequest(String targetUserUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final currentUid = currentUser.uid;

    final sentRef = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('connectionRequests')
        .doc(targetUserUid);

    final receivedRef = _firestore
        .collection('users')
        .doc(targetUserUid)
        .collection('connectionRequests')
        .doc(currentUid);

    final alreadyAccepted = await sentRef.get();
    if (alreadyAccepted.exists &&
        alreadyAccepted.data()?['status'] == 'accepted') return;

    // Add request to receiver's connectionRequests
    await receivedRef.set({
      'fromUid': currentUid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 🔔 Add notification for the receiver
    await _firestore
        .collection('users')
        .doc(targetUserUid)
        .collection('notifications')
        .add({
      'type': 'request',
      'read': false,
      'from': currentUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> respondToRequest(String fromUid, bool accepted) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUid = currentUser.uid;

    final receiverRequestRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('connectionRequests')
        .doc(fromUid);

    final senderRequestRef = FirebaseFirestore.instance
        .collection('users')
        .doc(fromUid)
        .collection('connectionRequests')
        .doc(currentUid);

    await receiverRequestRef.update({
      'status': accepted ? 'accepted' : 'rejected',
      'read': true,
    });

    await senderRequestRef.set({
      'fromUid': currentUid,
      'status': accepted ? 'accepted' : 'rejected',
      'timestamp': FieldValue.serverTimestamp(),
      'read': true,
    });

    if (accepted) {
      final batch = FirebaseFirestore.instance.batch();

      // Add to both users' connections
      final currentUserConnectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('connections')
          .doc(fromUid);

      final fromUserConnectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(fromUid)
          .collection('connections')
          .doc(currentUid);

      batch.set(currentUserConnectionRef, {'connectedAt': Timestamp.now()});
      batch.set(fromUserConnectionRef, {'connectedAt': Timestamp.now()});

      // Increment connection counts
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUid);
      final fromUserRef =
          FirebaseFirestore.instance.collection('users').doc(fromUid);

      batch.update(currentUserRef, {
        'connectionsCount': FieldValue.increment(1),
      });
      batch.update(fromUserRef, {
        'connectionsCount': FieldValue.increment(1),
      });

      await batch.commit();
    }
  }

  static Future<void> cancelRequest(String targetUserUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(targetUserUid)
        .collection('connectionRequests')
        .doc(currentUser.uid)
        .delete();
  }

  static Future<void> removeMate(String targetUserUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await Future.wait([
      _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('connectionRequests')
          .doc(targetUserUid)
          .delete(),
      _firestore
          .collection('users')
          .doc(targetUserUid)
          .collection('connectionRequests')
          .doc(currentUser.uid)
          .delete(),
    ]);
  }

  final Map<String, Map<String, String>> connectionTexts = {
    'en': {
      'connections': 'Connections',
      'connectWithBusiness': 'Connect with Business',
      'connected': 'Connected',
      'pendingRequest': 'Pending Request',
      'sendRequest': 'Send Connection Request',
      'accept': 'Accept',
      'reject': 'Reject',
      'remove': 'Remove Connection',
      'noConnections': 'No Connections Yet',
      'mutualConnections': 'Mutual Connections',
      'viewProfile': 'View Profile',
      'message': 'Message',
    },
    'hi': {
      'connections': 'संपर्क',
      'connectWithBusiness': 'व्यवसाय से जुड़ें',
      'connected': 'जुड़ा हुआ',
      'pendingRequest': 'लंबित अनुरोध',
      'sendRequest': 'कनेक्शन अनुरोध भेजें',
      'accept': 'स्वीकार करें',
      'reject': 'अस्वीकार करें',
      'remove': 'कनेक्शन हटाएं',
      'noConnections': 'अभी तक कोई संपर्क नहीं है',
      'mutualConnections': 'पारस्परिक संपर्क',
      'viewProfile': 'प्रोफ़ाइल देखें',
      'message': 'संदेश',
    },
    'mr': {
      'connections': 'संपर्क',
      'connectWithBusiness': 'व्यवसायाशी जोडा',
      'connected': 'जोडलेले',
      'pendingRequest': 'प्रलंबित विनंती',
      'sendRequest': 'कनेक्शन विनंती पाठवा',
      'accept': 'स्वीकारा',
      'reject': 'नकारा',
      'remove': 'कनेक्शन काढा',
      'noConnections': 'अद्याप कोणतेही संपर्क नाहीत',
      'mutualConnections': 'परस्पर संपर्क',
      'viewProfile': 'प्रोफाइल पाहा',
      'message': 'संदेश',
    },
  };
}
