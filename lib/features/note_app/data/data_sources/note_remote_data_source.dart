import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class NoteRemoteDataSource {
  //save
  Future<void> saveNote(Map<String, dynamic> rawNote);

  //fetch
  Stream<List<Map<String, dynamic>>> getAllNotes();
  Future<void> deleteNote(String noteId);

  //check User Offline (if waiting For Pending offline notes(FireStore Off feat) took more than 3 seconds)
  Future<void> waitForNoteWrites();

  //clear if online (waiting stoped before 3 sec->notes stored online->clear offline cache [bcz we need to signout]).
  Future<void> clearLocalNoteCache();
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  static const String _collectionName = 'notes';
  final FirebaseFirestore _firebaseFirestore;

  NoteRemoteDataSourceImpl({required FirebaseFirestore firebasefireStore})
    : _firebaseFirestore = firebasefireStore;

  CollectionReference<Map<String, dynamic>> get _notescollection =>
      _firebaseFirestore.collection(_collectionName);

  @override
  Future<void> saveNote(Map<String, dynamic> rawNote) async {
    try {
      debugPrint('=== Note RDS >createNote Started ====');

      //extract id from Map
      String noteId = rawNote['id'] as String;

      //since fireStore provides id gen functionality
      //no need of extra uuid package now
      if (noteId.trim().isEmpty) {
        //if its brand new note , empt ids
        //gen
        //save noteId in var
        noteId = _notescollection.doc().id;

        //inject the fs generated id (for note ID) in Raw note
        rawNote['id'] = noteId;
      }

      // #Upsert behavior
      //check whether rawNote doc with that specific noteid
      //if present , take that doc ref
      //if not present, set with create a new one
      //<Map> bcz we specify what is core thing firestore will send us.
      //Box>env>letter (Map) .we didnt specify box
      final DocumentReference<Map<String, dynamic>> docRef = _notescollection
          .doc(noteId);

      //create note if not existed on that doc ref (or) update existing one
      //just perform action , no return
      await docRef
          .set(rawNote)
          .timeout(
            Duration(seconds: 3),
            onTimeout: () {
              //we trust fireStore online persistance feat to save notes on reconnect.
              debugPrint("Note saved locally. Will sync to cloud when online.");
              return;
            },
          );

      debugPrint(
        'Note RDS >createNote ENDED $rawNote with id : ${rawNote['id']} is UPSERTED',
      );
    } on FirebaseException catch (e) {
      debugPrint('Note RDS >createNote > FBException : $e');
    } catch (e) {
      debugPrint('Note RDS >createNote > other Error : $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getAllNotes() {
    try {
      debugPrint("NoteRDS>getAllNotes>Started======");

      //fetch curren user Auth ID (fetch only that list of notes where authId matches)
      final String currentUserAuthId = FirebaseAuth.instance.currentUser!.uid;

      //Integrating FireStore Offline persistence feature:
      //instead of .get (fetch from online db only .await and returning future)
      //use .snapShots (before making network call first fetch from offline cache & its stream)

      //notesCollRef will give -->colln obj(query snapshot)
      //give list of QDocSnp>each QDS contain map<>
      //so -->map<> directly
      //.sort --> sort by this key (String[Alpha],int [Numerically],dateTime.now()[Timestamp])
      final Stream<QuerySnapshot<Map<String, dynamic>>> querySnapShotStream =
          _notescollection
              .where('userId', isEqualTo: currentUserAuthId)
              .orderBy('createdAt', descending: true)
              .snapshots();
      //.get();

      //QS > List QDSnp : map -- each QDsn  -- raw map --.tolist
      //.docs not defined for stream .cant perform on stream
      //querySnapShotstream->map->querSnapShot->.docs gives list of docs->map docList->doc.data actual map -> toList
      //return this rawNoteList to main querySnapShot Stream.map
      // 3. Map the Firestore Stream to your custom Stream
      final Stream<List<Map<String, dynamic>>>
      rawNotesListStream = querySnapShotStream.map((querySnapShot) {
        // Since we typed the collection, querySnapShot.docs already knows its type.
        // We can cleanly map it without forced casts ('as Map<String, dynamic>').
        final List<Map<String, dynamic>> rawNotes = querySnapShot.docs
            .map((queryDoc) => queryDoc.data())
            .toList();

        // 4. MOVED the length print inside the map. (You can't call .length on a Stream)
        debugPrint(
          "NoteRds>getAllNotes> Stream updated: ${rawNotes.length} notes fetched from fireStore cache/online",
        );

        return rawNotes; // This returns the List to the Stream.map
      });

      // 5. Return the fully mapped stream to the Controller

      return rawNotesListStream;
    } on FirebaseException catch (e) {
      debugPrint("NoteRDS>getAllNotes caught FireBase exception > $e");
      rethrow;
    } catch (e) {
      debugPrint(
        "NoteRds>getAllNotes caught Exception (other that FireBase Exc) :$e",
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(String noteId) async {
    try {
      debugPrint("NoteRDS>deleteNote>Started======");

      //get the doc Ref
      final DocumentReference docRef = _notescollection.doc(noteId);

      await docRef.delete().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint("Note deleted locally. Will sync to cloud when online.");
          return;
        },
      );
      ;

      debugPrint('[Firestore] Successfully deleted note with ID: $noteId');
    } on FirebaseException catch (e) {
      debugPrint("NoteRDS>delete Note caught FireBase exception > $e");
      rethrow;
    } catch (e) {
      debugPrint(
        "NoteRds>deleteNote caught Exception (other that FireBase Exc) :$e",
      );
      rethrow;
    }
  }

  @override
  Future<void> waitForNoteWrites() async {
    //since we clicked save button->FS trying to save notes ->if offline , cached .
    //after cache still wait for internet->we wait for pending writes , if more than 3 seconds
    //.timeOut Throws TimeOut error
    await _firebaseFirestore.waitForPendingWrites().timeout(
      Duration(seconds: 3),
    );
  }

  //clear in NoteViewctr noteViewSignOut after successfully notes pushed/saved online
  @override
  Future<void> clearLocalNoteCache() async {
    try {
      //!st terminate the fireStore off feat which is trying to save notes checking for reconnect
      //bcz user chosen to force signout , discarding edits

      await FirebaseFirestore.instance.terminate();
      // 2. NOW it is safe to clear the offline data
      await FirebaseFirestore.instance.clearPersistence();
    } catch (e) {
      debugPrint("Error clearing cache: $e");
      throw Exception(e);
    }
  }
}
