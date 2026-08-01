import 'package:note_app/features/note_app/data/data_sources/note_local_data_source.dart';
import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _localDataSource;

  NoteRepositoryImpl({required NoteLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
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
  }
}
