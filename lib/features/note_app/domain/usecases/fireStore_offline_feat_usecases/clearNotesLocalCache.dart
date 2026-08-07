import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class ClearNotesLocalCacheUseCase {
  final NoteRepository _noteRepository;
  ClearNotesLocalCacheUseCase({required NoteRepository noteRepository})
    : _noteRepository = noteRepository;

  Future<void> call() async {
    await _noteRepository.clearLocalNoteCache();
  }
}
