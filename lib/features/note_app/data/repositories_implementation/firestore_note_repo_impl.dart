import 'package:flutter/material.dart';
import 'package:note_app/features/note_app/data/data_sources/firestore/note_remote_datasources.dart/note_remote_data_source.dart';
import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class FireStoreNoteRepoImpl implements NoteRepository {
  //--------- Note Remote DS (FireStore)-------------

  final NoteRemoteDataSource _noteRemoteDataSource;
  FireStoreNoteRepoImpl({required NoteRemoteDataSource noteRDS})
    : _noteRemoteDataSource = noteRDS;

  @override
  Stream<List<NoteEntity>> getAllNotes() {
    debugPrint('NoteRepo impl> getAll Notes Started==============');

    Stream<List<Map<String, dynamic>>> rawList = _noteRemoteDataSource
        .getAllNotes();

    debugPrint('got ${rawList.length} notes from noteRDS(fireStore)');

    Stream<List<NoteEntity>> noteEntities = rawList.map((listRawJson) {
      final List<NoteEntity> noteEntityList = listRawJson.map((json) {
        return NoteModel.fromJson(json);
      }).toList();

      return noteEntityList;
    });

    return noteEntities;
  }

  @override
  Future<void> saveNote(NoteEntity note) async {
    debugPrint('NoteRepoimpl>saveNotes>saving the Note Started==============');
    debugPrint(
      'NoteRepoimpl>saveNotes>${note.mediaAttachments.length}mediaAttachments in note which\'s passed in param',
    );
    NoteModel noteModel = NoteModel.fromEntity(note);
    Map<String, dynamic> rawNote = noteModel.toJson();
    await _noteRemoteDataSource.saveNote(rawNote);
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _noteRemoteDataSource.deleteNote(noteId);
  }

  @override
  Future<void> waitForNoteWrites() async {
    //in NoteRDS:
    //since we clicked save button->FS trying to save notes ->if offline , cached .
    //after cache still wait for internet->we wait for pending writes , if more than 3 seconds
    //.timeOut Throws TimeOut error

    await _noteRemoteDataSource.waitForNoteWrites();
  }

  //clear in ctr signOut after successfully notes pushed/saved online
  @override
  Future<void> clearLocalNoteCache() async {
    await _noteRemoteDataSource.clearLocalNoteCache();
  }

  //--------Note LDS (Get Storage)---------------------

  /*  final NoteLocalDataSource _localDataSource;

  NoteRepositoryImpl({required NoteLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

 
  @override
  List<NoteEntity> getNotes() {
    List<dynamic>? rawData = _localDataSource.getNotesFromStorage();
    List<dynamic> safeList = rawData ?? [];

    // THE FIX: We removed .toEntity()
    // By adding <NoteEntity> after map, we tell Dart to treat these NoteModels as NoteEntities.
    List<NoteEntity> listOfNoteEntities = safeList
        .map<NoteEntity>((rawMap) => NoteModel.fromJson(rawMap))
        .toList();

    return listOfNoteEntities;
  }

  @override
  Future<void> saveNotes(List<NoteEntity> notes) async {
    // FIX 3: Use the fromEntity translator you built
    List<NoteModel> noteModels = notes.map((entity) {
      return NoteModel.fromEntity(entity);
    }).toList();

    // Model --> toJson
    List<Map<String, dynamic>> rawData = noteModels
        .map((noteModel) => noteModel.toJson())
        .toList();

    if (notes.isNotEmpty) {
      print(
        'rep Impl -> saveNotes -> Latest note title is -> ${notes[0].title}',
      );
    }
    await _localDataSource.saveNotesToStorage(rawData);
  } */
}
