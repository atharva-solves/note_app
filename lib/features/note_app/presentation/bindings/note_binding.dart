import 'package:get/get.dart';
import 'package:note_app/core/services/local_storage_service.dart';
import 'package:note_app/features/note_app/data/data_sources/note_local_data_source.dart';
import 'package:note_app/features/note_app/data/repositories_implementation/note_repositories_impl.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';
import 'package:note_app/features/note_app/domain/usecases/add_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/delete_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/get_notes_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/toggle_important_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/update_note_usecase.dart';
import 'package:note_app/features/note_app/presentation/controllers/note_controller.dart';

//why?
//all Init SoC and SRP for UI(only find not init).
//mem management. bindings attached to getPage.only use/init when neded.
//                delete as soon as page left

class NoteBinding extends Bindings {
  @override
  void dependencies() {
    //waterfall init
    //first (StorServ is init  globally in main before even app is created )
    //lazy put -> init only when actually called and needed

    //[1] Data source
    Get.lazyPut(
      () => NoteLocalDataSource(storageService: Get.find<StorageService>()),
    );

    //[2] Repo: bind abstract contract and implemen worker together.
    //<abst> ,()=>abImpl() Diff!!

    Get.lazyPut<NoteRepository>(
      () => NoteRepositoriesImpl(
        localDataSource: Get.find<NoteLocalDataSource>(),
      ),
    );

    //[3] UseCases (single action seperated Business logic)
    Get.lazyPut(
      () => GetNotesUsecase(noteRepository: Get.find<NoteRepository>()),
    );
    Get.lazyPut(
      () => AddNoteUsecase(noteRepository: Get.find<NoteRepository>()),
    );
    Get.lazyPut(
      () => UpdateNoteUsecase(noteRepository: Get.find<NoteRepository>()),
    );
    Get.lazyPut(
      () => DeleteNoteUsecase(noteRepository: Get.find<NoteRepository>()),
    );
    Get.lazyPut(
      () => ToggleImportantUsecase(noteRepository: Get.find<NoteRepository>()),
    );

    //[4]Ctr (brin of UI,UI action trigger 5 usecases,actions)
    Get.lazyPut(
      () => NoteController(
        addNoteUsecase: Get.find<AddNoteUsecase>(),
        getNotesUsecase: Get.find<GetNotesUsecase>(),
        updateNoteUsecase: Get.find<UpdateNoteUsecase>(),
        deleteNoteUsecase: Get.find<DeleteNoteUsecase>(),
        toggleImportantUsecase: Get.find<ToggleImportantUsecase>(),
      ),
    );
  }
}
