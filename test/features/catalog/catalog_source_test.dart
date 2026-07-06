import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/dto/catalog_dto.dart';
import 'package:radha_app/features/catalog/providers/product_browse_providers.dart';

/// Minimal fake ApiClient — only the catalog methods the browse controller
/// touches are implemented; everything else routes through noSuchMethod (and is
/// never called in these tests).
class _FakeApiClient implements ApiClient {
  _FakeApiClient({this.categories, this.page, this.error});

  final List<CatalogCategory>? categories;
  final CatalogBrowsePage? page;
  final Object? error;

  @override
  Future<List<CatalogCategory>> getCatalogCategories() async {
    if (error != null) throw error!;
    return categories ?? const <CatalogCategory>[];
  }

  @override
  Future<CatalogBrowsePage> getCatalogProducts({
    String? category,
    String? q,
    String? sort,
    String? cursor,
    int? limit,
  }) async {
    if (error != null) throw error!;
    return page ?? const CatalogBrowsePage(items: <CatalogProductItem>[]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProviderContainer _containerWith(_FakeApiClient fake) {
  final c = ProviderContainer(
    overrides: [apiClientProvider.overrideWithValue(fake)],
  );
  addTearDown(c.dispose);
  return c;
}

const _matchingCategory = CatalogCategory(
  id: 'cat-uuid-1',
  name: 'Biscuits & Snacks',
  slug: 'biscuits-snacks',
  sortOrder: 0,
);

DioException _dio(DioExceptionType type, {int? status}) => DioException(
  requestOptions: RequestOptions(path: '/api/v1/catalog/products'),
  type: type,
  response: status == null
      ? null
      : Response(
          requestOptions: RequestOptions(path: '/api/v1/catalog/products'),
          statusCode: status,
        ),
);

void main() {
  const arg = ('biscuits', CatalogSort.health);

  test('successful fetch reports a LIVE source', () async {
    final fake = _FakeApiClient(
      categories: const [_matchingCategory],
      page: const CatalogBrowsePage(
        items: [
          CatalogProductItem(id: 'p1', ean: '8901234567890', name: 'Parle-G'),
        ],
      ),
    );
    final container = _containerWith(fake);

    final state = await container.read(categoryBrowseProvider(arg).future);
    expect(state.source, CatalogSource.live);
    expect(state.server, isNotEmpty);
  });

  test(
    'connection error reports OFFLINE and still serves the bundled catalog',
    () async {
      final fake = _FakeApiClient(
        error: _dio(DioExceptionType.connectionError),
      );
      final container = _containerWith(fake);

      final state = await container.read(categoryBrowseProvider(arg).future);
      expect(state.source, CatalogSource.offline);
      expect(state.server, isEmpty); // no live rows, but no error thrown
    },
  );

  test('HTTP 500 reports UNAVAILABLE (distinct from offline)', () async {
    final fake = _FakeApiClient(
      error: _dio(DioExceptionType.badResponse, status: 500),
    );
    final container = _containerWith(fake);

    final state = await container.read(categoryBrowseProvider(arg).future);
    expect(state.source, CatalogSource.unavailable);
  });

  test('unresolved category (empty categories) reports UNAVAILABLE', () async {
    final fake = _FakeApiClient(
      categories: const <CatalogCategory>[],
      page: const CatalogBrowsePage(items: <CatalogProductItem>[]),
    );
    final container = _containerWith(fake);

    final state = await container.read(categoryBrowseProvider(arg).future);
    expect(state.source, CatalogSource.unavailable);
  });

  test('error classifier maps connection-class errors to offline', () {
    expect(
      catalogSourceForError(_dio(DioExceptionType.connectionTimeout)),
      CatalogSource.offline,
    );
    expect(
      catalogSourceForError(_dio(DioExceptionType.badResponse, status: 404)),
      CatalogSource.unavailable,
    );
    expect(catalogSourceForError(StateError('x')), CatalogSource.unavailable);
  });
}
