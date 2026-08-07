import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_out_usecase.dart';
import 'package:note_app/features/note_app/data/data_sources/note_remote_data_source.dart';
import 'package:note_app/features/note_app/data/repositories_implementation/note_repository_impl.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';
import 'package:note_app/features/note_app/domain/usecases/add_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/delete_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/fireStore_offline_feat_usecases/clearNotesLocalCache.dart';
import 'package:note_app/features/note_app/domain/usecases/fireStore_offline_feat_usecases/waitForNotesWrite.dart';
import 'package:note_app/features/note_app/domain/usecases/get_notes_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/toggle_important_usecase.dart';
import 'package:note_app/features/note_app/presentation/controllers/note_controller.dart';

//why?
//all Init SoC and SRP for UI(only find not init).
//mem management. bindings attached to getPage.only use/init when neded.
//                delete as soon as page left

class NoteBinding extends Bindings {
  @override
  void dependencies() {
    //waterfall init
    //first (StorServ is init  globally in main before even app is created ) (InitialBindings)
    //lazy put -> init only when actually called and needed

    //[1] Data source
    //RDS Firestore first root dependency
    Get.lazyPut<NoteRemoteDataSource>(
      () => NoteRemoteDataSourceImpl(
        firebasefireStore: FirebaseFirestore.instance,
      ),
    );
    //LDS Get storage
    /*  Get.lazyPut(
      () => NoteLocalDataSource(storageService: Get.find<StorageService>()),
    ); */

    //[2] Repo: bind abstract contract and implemen worker together.
    //<abst> ,()=>abImpl() Diff!!

    //RDS FireStore
    Get.lazyPut<NoteRepository>(
      () => NoteRepositoryImpl(noteRDS: Get.find<NoteRemoteDataSource>()),
    );
    /*  Get.lazyPut<NoteRepository>(
      () => NoteRepositoryImpl(
        localDataSource: Get.find<NoteLocalDataSource>(),
      ),
    ); */

    //[3] UseCases (single action seperated Business logic)
    Get.lazyPut(
      () => GetNotesUsecase(noteRepository: Get.find<NoteRepository>()),
    );
    Get.lazyPut(
      () => AddNoteUsecase(noteRepository: Get.find<NoteRepository>()),
    );
    /* Get.lazyPut(
      //firestore RDS Upsert , .set , so no need

      //() => UpdateNoteUsecase(noteRepository: Get.find<NoteRepository>()),
    ); */
    Get.lazyPut(
      () => DeleteNoteUsecase(noteRepository: Get.find<NoteRepository>()),
    );
    Get.lazyPut(
      () => ToggleImportantUsecase(noteRepository: Get.find<NoteRepository>()),
    );
Get.lazyPut(
      () => WaitfornoteswriteUsecase(noteRepository: Get.find<NoteRepository>()),
    );
    Get.lazyPut(
      () => ClearNotesLocalCacheUseCase(noteRepository: Get.find<NoteRepository>()),
    );

    //[4]Ctr (brin of UI,UI action trigger 5 usecases,actions)
    Get.lazyPut(
      () => NoteController(
        addNoteUsecase: Get.find<AddNoteUsecase>(),
        getNotesUsecase: Get.find<GetNotesUsecase>(),
        //not needed for RDS FireStore bcz Upsert .set

        //updateNoteUsecase: Get.find<UpdateNoteUsecase>(),
        deleteNoteUsecase: Get.find<DeleteNoteUsecase>(),
        toggleImportantUsecase: Get.find<ToggleImportantUsecase>(),
        waitfornoteswriteUsecase:Get.find<WaitfornoteswriteUsecase>(),
        clearnoteslocalcacheUseCase:Get.find<ClearNotesLocalCacheUseCase>(),
        signOutUsecase:Get.find<SignOutUsecase>(),
      ),
    );
  }
}
