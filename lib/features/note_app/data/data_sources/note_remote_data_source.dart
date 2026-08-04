import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

abstract class NoteRemoteDataSource {
  //save
  Future<void> saveNote(Map<String, dynamic> rawNote);

  //fetch
  Future<List<Map<String, dynamic>>> getAllNotes();
  Future<void> deleteNote(String noteId);
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
      //check whether rawNote doc with that specific uuid
      //if present , take that doc ref
      //if not present, set with create a new one
      //<Map> bcz we specify what is core thing firestore will send us.
      //Box>env>letter (Map) .we didnt specify box
      final DocumentReference<Map<String, dynamic>> docRef = _notescollection
          .doc(noteId);

      //create note if not existed on that doc ref (or) update existing one
      //just perform action
      await docRef.set(rawNote);

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
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    try {
      debugPrint("NoteRDS>getAllNotes>Started======");

      //notesCollRef will give -->colln obj(query snapshot)
      //give list of QDocSnp>each QDS contain map<>
      //so -->map<> directly
      //.sort --> sort by this key (String[Alpha],int [Numerically],dateTime.now()[Timestamp])
      final QuerySnapshot<Map<String, dynamic>> querySnapShot =
          await _notescollection.orderBy('createdAt', descending: true).get();

      //QS > List QDSnp : map -- each QDsn  -- raw map --.tolist

      final List<Map<String, dynamic>> notesList = querySnapShot.docs
          .map((queryDoc) => queryDoc.data())
          .toList();

      debugPrint(
        "NoteRds>getAllNotes>${notesList.length} notes fetched from fireStore",
      );
      return notesList;
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

      await docRef.delete();

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
}
