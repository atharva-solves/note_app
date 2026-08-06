import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class ClearnoteslocalcacheUseCase {
  final NoteRepository _noteRepository;
  ClearnoteslocalcacheUseCase({required NoteRepository noteRepository})
    : _noteRepository = noteRepository;

  Future<void> call() async {
    await _noteRepository.clearLocalNoteCache();
  }
}
