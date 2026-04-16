import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:frontend/src/configs/injector/injector_conf.dart';
import 'package:frontend/src/core/errors/failures.dart';

import 'package:frontend/src/features/chat/domain/entities/chat_entity.dart';
import 'package:frontend/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:frontend/src/features/chat/domain/usecases/fetch_chat_items_usecase.dart';
import 'package:frontend/src/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:frontend/src/features/chat/presentation/pages/mochi_direct_messages_page.dart';

import 'package:frontend/src/features/home/domain/entities/home_entity.dart';
import 'package:frontend/src/features/home/domain/repositories/home_repository.dart';
import 'package:frontend/src/features/home/domain/usecases/fetch_home_items_usecase.dart';
import 'package:frontend/src/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:frontend/src/features/home/presentation/pages/mochi_main_page.dart';

import 'package:frontend/src/features/profile/domain/entities/profile_entity.dart';
import 'package:frontend/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:frontend/src/features/profile/domain/usecases/fetch_profile_items_usecase.dart';
import 'package:frontend/src/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:frontend/src/features/profile/presentation/pages/mochi_profile_page.dart';

void main() {
  setUp(() async {
    await getIt.reset();

    getIt.registerFactory<HomeBloc>(
      () => HomeBloc(FetchHomeItemsUseCase(_FakeHomeRepository())),
    );

    getIt.registerFactory<ProfileBloc>(
      () => ProfileBloc(FetchProfileItemsUseCase(_FakeProfileRepository())),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('Home screen renders feed items from bloc data', (tester) async {
    await _pumpPage(tester, const MochiMainPage());

    expect(find.text('Mochi Main'), findsOneWidget);
    expect(find.text('Test Author'), findsOneWidget);
    expect(find.text('API feed item from widget test'), findsOneWidget);
  });

  testWidgets('DM screen renders conversation list', (tester) async {
    await _pumpPage(tester, const MochiDirectMessagesPage());

    expect(find.text('Mochi Direct Messages'), findsOneWidget);
    expect(find.text('Alice Nguyen'), findsAtLeastNWidgets(1));
    expect(find.text('Ping from widget test'), findsOneWidget);
  });

  testWidgets('Profile screen renders user identity and stats', (tester) async {
    await _pumpPage(tester, const MochiProfilePage());

    expect(find.text('Mochi Profile'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('@test_user'), findsOneWidget);
    expect(find.text('1 shown'), findsOneWidget);
  });
}

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(MaterialApp(home: page));
  await tester.pumpAndSettle();
}

class _FakeHomeRepository implements HomeRepository {
  @override
  Future<Either<Failure, List<HomeEntity>>> fetchItems() async {
    return right(const [
      HomeEntity(
        id: 'person_1',
        kind: 'person',
        title: 'Story User',
        isOnline: true,
      ),
      HomeEntity(
        id: 'post_1',
        kind: 'post',
        title: 'Test Author',
        subtitle: 'API feed item from widget test',
        likesCount: 12,
        commentsCount: 3,
        minutesAgo: 5,
      ),
    ]);
  }
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Either<Failure, List<ProfileEntity>>> fetchItems() async {
    return right(const [
      ProfileEntity(
        id: 'user_1',
        displayName: 'Test User',
        username: 'test_user',
        bio: 'Profile loaded from widget test',
        postsCount: 12,
        friendsCount: 34,
        posts: [ProfilePostPreview(id: 'post_1', likesCount: 7)],
      ),
    ]);
  }
}
