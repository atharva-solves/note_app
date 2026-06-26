//actuall implementation
//repo <--repoImpl-->Local Storage DATA SOURCE

//why?
//1.  Single Responsibility
//    (why not ctr-->Data source? ctrl only UI update.not second responsibitlity o translating data or multiple Data source manage)

//2. future proof swap :if firebase integration.
//   without repo, direct LDS conn ,each code change from LDS to FB in UI
//   with repo ,Ctr only talk to boss(reop).

import 'package:note_app/features/note_app/data/data_sources/note_local_data_source.dart';
import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class NoteRepositoriesImpl implements NoteRepository {
  //fin _fields,construct,@ov meth
  final NoteLocalDataSource _localDataSource;

  NoteRepositoriesImpl({required NoteLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  //read
  @override
  List<NoteModel> getNotes() {
    //raw data fetch - map,conv -store in var- return

    List<dynamic> rawData = _localDataSource.getNotesFromStorage();
    List<NoteModel> listOfNoteModel = rawData
        .map((rawMap) => NoteModel.fromJson(rawMap))
        .toList();

    return listOfNoteModel;
  }

  //write
  @override
  Future<void> saveNotes(List<NoteModel> notes) async {
    //noteM--toJson--send.
    List<Map<String, dynamic>> rawData = notes
        .map((noteModel) => noteModel.toJson())
        .toList();

    await _localDataSource.saveNotesToStorage(rawData);
  }
}
