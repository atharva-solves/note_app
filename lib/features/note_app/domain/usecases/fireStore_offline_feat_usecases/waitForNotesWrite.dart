import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class WaitfornoteswriteUsecase {
  final NoteRepository _noteRepository;
  WaitfornoteswriteUsecase({required NoteRepository noteRepository})
    : _noteRepository = noteRepository;

  Future<void> call() async {
    await _noteRepository.waitForNoteWrites();
  }
}
