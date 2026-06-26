import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class GetNotesUsecase {
  //UC<--only talks to-->Repo (abstract boss)
  //fin var (instance),constr,meth

  final NoteRepository noteRepository;

  //contructor
  GetNotesUsecase({required this.noteRepository});

  //actual method
  List<NoteModel> execute() => noteRepository.getNotes();
}
