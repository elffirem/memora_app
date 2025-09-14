import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/notes/data/datasources/notes_local_datasource.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import 'notes_api_service.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/notes/domain/usecases/get_notes_usecase.dart';
import '../../features/notes/domain/usecases/create_note_usecase.dart';
import '../../features/notes/domain/usecases/update_note_usecase.dart';
import '../../features/notes/domain/usecases/delete_note_usecase.dart';
import '../../features/notes/domain/usecases/toggle_pin_note_usecase.dart';
import '../../features/notes/domain/usecases/summarize_note_usecase.dart';
import '../../features/notes/domain/usecases/clear_all_notes_usecase.dart';
import '../../features/notes/presentation/bloc/notes_bloc.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // External dependencies
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton(() => NotesApiService());

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(getIt(), getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  
  getIt.registerLazySingleton(() => GetNotesUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => TogglePinNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => SummarizeNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => ClearAllNotesUseCase(getIt()));

  // Blocs
  getIt.registerFactory(() => AuthBloc(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    logoutUseCase: getIt(),
  ));
  
  getIt.registerFactory(() => NotesBloc(
    getNotesUseCase: getIt(),
    createNoteUseCase: getIt(),
    updateNoteUseCase: getIt(),
    deleteNoteUseCase: getIt(),
    togglePinNoteUseCase: getIt(),
    summarizeNoteUseCase: getIt(),
    clearAllNotesUseCase: getIt(),
  ));
}



