const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const MAP_FILE = path.join(ROOT, 'prototype-module-route-map.json');
const MODULE_ORDER = ['auth', 'home', 'reels', 'chat', 'profile'];
const MODULES_TO_BOOTSTRAP = ['home', 'chat', 'profile', 'reels'];

if (!fs.existsSync(MAP_FILE)) {
  console.error('Missing prototype-module-route-map.json');
  process.exit(1);
}

const mapData = JSON.parse(fs.readFileSync(MAP_FILE, 'utf8'));
const mappings = Array.isArray(mapData.mappings) ? mapData.mappings : [];

if (mappings.length === 0) {
  console.error('No mappings found in prototype-module-route-map.json');
  process.exit(1);
}

const homeEntry =
  mappings.find((m) => m.pageClass === 'MochiMainPage') || mappings[0];

function normalizeNewlines(text) {
  return String(text).replace(/\r\n/g, '\n');
}

function toLowerCamelCase(input) {
  return String(input)
    .split('_')
    .filter(Boolean)
    .map((part, index) => {
      if (index === 0) return part;
      return part.charAt(0).toUpperCase() + part.slice(1);
    })
    .join('');
}

function toPascalCase(input) {
  return String(input)
    .split(/[^a-zA-Z0-9]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join('');
}

function classNameToTitle(className) {
  return String(className)
    .replace(/(Page|Screen)$/, '')
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .replace(/([A-Za-z])(\d)/g, '$1 $2')
    .replace(/(\d)([A-Za-z])/g, '$1 $2')
    .trim();
}

function makeLegacySkeletonPageContent(className) {
  return `import 'package:flutter/material.dart';\n\nclass ${className} extends StatelessWidget {\n  const ${className}({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return const Scaffold(\n      body: Center(\n        child: Text('${className}'),\n      ),\n    );\n  }\n}\n`;
}

function makeStandardSkeletonPageContent(className) {
  const title = classNameToTitle(className);
  return `import 'package:flutter/material.dart';\n\nimport '../../../../widgets/feature_page_scaffold.dart';\n\nclass ${className} extends StatelessWidget {\n  const ${className}({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return const FeaturePageScaffold(\n      title: '${title}',\n      isLoading: false,\n    );\n  }\n}\n`;
}

function isLegacySkeletonPage(existingContent, className) {
  return (
    normalizeNewlines(existingContent).trim() ===
    normalizeNewlines(makeLegacySkeletonPageContent(className)).trim()
  );
}

function ensureParentDirectory(filePath) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

const baseRoutes = [
  {
    enumName: 'welcome',
    path: '/',
    pageClass: 'WelcomeScreen',
    module: 'root',
  },
  {
    enumName: 'login',
    path: '/login',
    pageClass: 'LoginScreen',
    module: 'root',
  },
  {
    enumName: 'register',
    path: '/register',
    pageClass: 'RegisterScreen',
    module: 'root',
  },
  {
    enumName: 'auth',
    path: '/auth',
    pageClass: null,
    module: 'auth',
  },
  {
    enumName: 'home',
    path: '/home',
    pageClass: homeEntry.pageClass,
    module: 'home',
  },
  {
    enumName: 'reels',
    path: '/reels',
    pageClass: null,
    module: 'reels',
  },
  {
    enumName: 'chat',
    path: '/chat',
    pageClass: null,
    module: 'chat',
  },
  {
    enumName: 'profile',
    path: '/profile',
    pageClass: null,
    module: 'profile',
  },
];

const authAliasRoutes = [
  {
    enumName: 'authLogin',
    path: '/auth/login',
    pageClass: 'LoginScreen',
    module: 'auth',
  },
  {
    enumName: 'authRegister',
    path: '/auth/register',
    pageClass: 'RegisterScreen',
    module: 'auth',
  },
];

const generatedRoutes = mappings.map((m) => ({
  enumName: toLowerCamelCase(m.routeName),
  path: m.routePath,
  pageClass: m.pageClass,
  module: m.module,
}));

const allRoutes = [...baseRoutes, ...authAliasRoutes, ...generatedRoutes];

const enumNames = new Set();
for (const route of allRoutes) {
  if (enumNames.has(route.enumName)) {
    console.error(`Duplicate enum name: ${route.enumName}`);
    process.exit(1);
  }
  enumNames.add(route.enumName);
}

const routePaths = new Set();
for (const route of allRoutes) {
  if (routePaths.has(route.path)) {
    console.error(`Duplicate route path: ${route.path}`);
    process.exit(1);
  }
  routePaths.add(route.path);
}

const moduleRoots = new Map(
  baseRoutes
    .filter((route) => route.module !== 'root')
    .map((route) => [route.module, route]),
);

const groupedModuleRoutes = Object.fromEntries(
  MODULE_ORDER.map((module) => [module, []]),
);

for (const route of generatedRoutes) {
  if (!groupedModuleRoutes[route.module]) {
    groupedModuleRoutes[route.module] = [];
  }

  groupedModuleRoutes[route.module].push(route);
}

groupedModuleRoutes.auth = [
  ...authAliasRoutes,
  ...(groupedModuleRoutes.auth || []),
];

function extractChildPath(module, fullPath) {
  const prefix = `/${module}/`;

  if (!fullPath.startsWith(prefix)) {
    throw new Error(
      `Route path ${fullPath} does not start with expected module prefix ${prefix}`,
    );
  }

  return fullPath.slice(prefix.length);
}

function toRoutesRelativeExport(filePath) {
  const normalized = filePath.replace(/\\/g, '/');
  const prefix = 'lib/src/';

  if (!normalized.startsWith(prefix)) {
    throw new Error(`Unexpected pageFile path: ${filePath}`);
  }

  return `../${normalized.slice(prefix.length)}`;
}

function buildAppRoutePathContent() {
  const lines = [];
  lines.push('enum AppRoutes {');

  for (const route of allRoutes) {
    lines.push(`  ${route.enumName}(path: '${route.path}'),`);
  }

  lines.push(';');
  lines.push('');
  lines.push('  final String path;');
  lines.push('  const AppRoutes({required this.path});');
  lines.push('}');

  return `${lines.join('\n')}\n`;
}

function buildAppRouteConfContent() {
  const lines = [];
  lines.push("import 'package:go_router/go_router.dart';");
  lines.push('');
  lines.push("import 'app_route_path.dart';");
  lines.push("import 'routes.dart';");
  lines.push('');
  lines.push('class AppRoutesConf {');
  lines.push('  GoRouter get router => _router;');
  lines.push('');
  lines.push('  late final GoRouter _router = GoRouter(');
  lines.push('    initialLocation: AppRoutes.welcome.path,');
  lines.push('    debugLogDiagnostics: true,');
  lines.push('    routes: [');

  for (const route of baseRoutes.filter((item) => item.module === 'root')) {
    lines.push('      GoRoute(');
    lines.push(`        path: AppRoutes.${route.enumName}.path,`);
    lines.push(`        name: AppRoutes.${route.enumName}.name,`);
    lines.push(`        builder: (context, state) => const ${route.pageClass}(),`);
    lines.push('      ),');
  }

  for (const module of MODULE_ORDER) {
    const moduleRoot = moduleRoots.get(module);
    if (!moduleRoot) {
      continue;
    }

    const children = groupedModuleRoutes[module] || [];

    lines.push('      GoRoute(');
    lines.push(`        path: AppRoutes.${moduleRoot.enumName}.path,`);
    lines.push(`        name: AppRoutes.${moduleRoot.enumName}.name,`);

    if (moduleRoot.pageClass) {
      lines.push(
        `        builder: (context, state) => const ${moduleRoot.pageClass}(),`,
      );
    } else {
      const fallbackRoute = children[0]
        ? `AppRoutes.${children[0].enumName}.path`
        : 'AppRoutes.home.path';
      lines.push('        redirect: (context, state) {');
      lines.push(
        `          if (state.matchedLocation == AppRoutes.${moduleRoot.enumName}.path) {`,
      );
      lines.push(`            return ${fallbackRoute};`);
      lines.push('          }');
      lines.push('          return null;');
      lines.push('        },');
    }

    lines.push('        routes: [');
    for (const child of children) {
      lines.push('          GoRoute(');
      lines.push(`            path: '${extractChildPath(module, child.path)}',`);
      lines.push(`            name: AppRoutes.${child.enumName}.name,`);
      lines.push(
        `            builder: (context, state) => const ${child.pageClass}(),`,
      );
      lines.push('          ),');
    }
    lines.push('        ],');
    lines.push('      ),');
  }

  lines.push('    ],');
  lines.push('  );');
  lines.push('}');

  return `${lines.join('\n')}\n`;
}

function buildRoutesBarrelContent() {
  const existingExports = [
    "export '../features/auth/presentation/pages/welcome_screen.dart';",
    "export '../features/auth/presentation/pages/login_screen.dart';",
    "export '../features/auth/presentation/pages/register_screen.dart';",
    "export '../features/auth/domain/entities/user_entity.dart';",
    "export '../core/cache/secure_local_storage.dart';",
    "export '../configs/injector/injector_conf.dart';",
  ];

  const generatedExports = [
    ...new Set(mappings.map((m) => toRoutesRelativeExport(m.pageFile))),
  ]
    .sort()
    .map((item) => `export '${item}';`);

  const all = [...existingExports, ...generatedExports];
  return `${all.join('\n')}\n`;
}

function buildFeatureScaffoldFiles(module) {
  const modulePascal = toPascalCase(module);
  const fetchUseCase = `Fetch${modulePascal}ItemsUseCase`;
  const entityClass = `${modulePascal}Entity`;
  const repositoryClass = `${modulePascal}Repository`;
  const repositoryImplClass = `${modulePascal}RepositoryImpl`;
  const localDataSourceClass = `${modulePascal}LocalDataSource`;
  const localDataSourceImplClass = `${modulePascal}LocalDataSourceImpl`;
  const remoteDataSourceClass = `${modulePascal}RemoteDataSource`;
  const remoteDataSourceImplClass = `${modulePascal}RemoteDataSourceImpl`;
  const modelClass = `${modulePascal}Model`;
  const blocClass = `${modulePascal}Bloc`;
  const eventClass = `${modulePascal}Event`;
  const stateClass = `${modulePascal}State`;
  const queryParamsClass = `${modulePascal}QueryParams`;
  const fetchedEventClass = `${modulePascal}FetchedEvent`;
  const initialStateClass = `${modulePascal}InitialState`;
  const loadingStateClass = `${modulePascal}LoadingState`;
  const successStateClass = `${modulePascal}SuccessState`;
  const failureStateClass = `${modulePascal}FailureState`;
  const dependencyClass = `${modulePascal}Dependency`;

  return {
    [`lib/src/features/${module}/domain/entities/${module}_entity.dart`]: `import 'package:equatable/equatable.dart';\n\nclass ${entityClass} extends Equatable {\n  final String id;\n\n  const ${entityClass}({required this.id});\n\n  @override\n  List<Object?> get props => [id];\n}\n`,
    [`lib/src/features/${module}/domain/repositories/${module}_repository.dart`]: `import 'package:fpdart/fpdart.dart';\n\nimport '../../../../core/errors/failures.dart';\nimport '../entities/${module}_entity.dart';\n\nabstract class ${repositoryClass} {\n  Future<Either<Failure, List<${entityClass}>>> fetchItems();\n}\n`,
    [`lib/src/features/${module}/domain/usecases/usecase_params.dart`]: `import 'package:equatable/equatable.dart';\n\nclass ${queryParamsClass} extends Equatable {\n  final int page;\n\n  const ${queryParamsClass}({this.page = 1});\n\n  @override\n  List<Object?> get props => [page];\n}\n`,
    [`lib/src/features/${module}/domain/usecases/fetch_${module}_items_usecase.dart`]: `import 'package:fpdart/fpdart.dart';\n\nimport '../../../../core/errors/failures.dart';\nimport '../../../../core/usecases/usecase.dart';\nimport '../entities/${module}_entity.dart';\nimport '../repositories/${module}_repository.dart';\nimport 'usecase_params.dart';\n\nclass ${fetchUseCase}\n    implements UseCase<List<${entityClass}>, ${queryParamsClass}> {\n  final ${repositoryClass} _repository;\n\n  ${fetchUseCase}(this._repository);\n\n  @override\n  Future<Either<Failure, List<${entityClass}>>> call(${queryParamsClass} params) {\n    return _repository.fetchItems();\n  }\n}\n`,
    [`lib/src/features/${module}/data/models/${module}_model.dart`]: `import '../../domain/entities/${module}_entity.dart';\n\nclass ${modelClass} extends ${entityClass} {\n  const ${modelClass}({required super.id});\n\n  factory ${modelClass}.fromJson(Map<String, dynamic> json) {\n    return ${modelClass}(id: json['id']?.toString() ?? '');\n  }\n\n  Map<String, dynamic> toJson() => {'id': id};\n}\n`,
    [`lib/src/features/${module}/data/datasources/${module}_local_datasource.dart`]: `import '../models/${module}_model.dart';\n\nabstract class ${localDataSourceClass} {\n  Future<List<${modelClass}>> fetchItems();\n}\n\nclass ${localDataSourceImplClass} implements ${localDataSourceClass} {\n  @override\n  Future<List<${modelClass}>> fetchItems() async {\n    return const [];\n  }\n}\n`,
    [`lib/src/features/${module}/data/datasources/${module}_remote_datasource.dart`]: `import '../models/${module}_model.dart';\n\nabstract class ${remoteDataSourceClass} {\n  Future<List<${modelClass}>> fetchItems();\n}\n\nclass ${remoteDataSourceImplClass} implements ${remoteDataSourceClass} {\n  @override\n  Future<List<${modelClass}>> fetchItems() async {\n    return const [];\n  }\n}\n`,
    [`lib/src/features/${module}/data/repositories/${module}_repository_impl.dart`]: `import 'package:fpdart/fpdart.dart';\n\nimport '../../../../core/errors/failures.dart';\nimport '../../domain/entities/${module}_entity.dart';\nimport '../../domain/repositories/${module}_repository.dart';\nimport '../datasources/${module}_local_datasource.dart';\nimport '../datasources/${module}_remote_datasource.dart';\n\nclass ${repositoryImplClass} implements ${repositoryClass} {\n  final ${remoteDataSourceClass} _remoteDataSource;\n  final ${localDataSourceClass} _localDataSource;\n\n  ${repositoryImplClass}(this._remoteDataSource, this._localDataSource);\n\n  @override\n  Future<Either<Failure, List<${entityClass}>>> fetchItems() async {\n    try {\n      final remoteItems = await _remoteDataSource.fetchItems();\n      if (remoteItems.isNotEmpty) {\n        return right(remoteItems);\n      }\n\n      final localItems = await _localDataSource.fetchItems();\n      return right(localItems);\n    } catch (_) {\n      return left(ServerFailure());\n    }\n  }\n}\n`,
    [`lib/src/features/${module}/presentation/bloc/${module}/${module}_bloc.dart`]: `import 'package:equatable/equatable.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\n\nimport '../../../domain/entities/${module}_entity.dart';\nimport '../../../domain/usecases/fetch_${module}_items_usecase.dart';\nimport '../../../domain/usecases/usecase_params.dart';\n\npart '${module}_event.dart';\npart '${module}_state.dart';\n\nclass ${blocClass} extends Bloc<${eventClass}, ${stateClass}> {\n  final ${fetchUseCase} _fetchItemsUseCase;\n\n  ${blocClass}(this._fetchItemsUseCase) : super(const ${initialStateClass}()) {\n    on<${fetchedEventClass}>(_onFetched);\n  }\n\n  Future<void> _onFetched(${fetchedEventClass} event, Emitter<${stateClass}> emit) async {\n    emit(const ${loadingStateClass}());\n\n    final result = await _fetchItemsUseCase.call(\n      ${queryParamsClass}(page: event.page),\n    );\n\n    result.fold(\n      (failure) => emit(const ${failureStateClass}('Unable to load data')),\n      (items) => emit(${successStateClass}(items)),\n    );\n  }\n}\n`,
    [`lib/src/features/${module}/presentation/bloc/${module}/${module}_event.dart`]: `part of '${module}_bloc.dart';\n\nsealed class ${eventClass} extends Equatable {\n  const ${eventClass}();\n\n  @override\n  List<Object?> get props => [];\n}\n\nclass ${fetchedEventClass} extends ${eventClass} {\n  final int page;\n\n  const ${fetchedEventClass}({this.page = 1});\n\n  @override\n  List<Object?> get props => [page];\n}\n`,
    [`lib/src/features/${module}/presentation/bloc/${module}/${module}_state.dart`]: `part of '${module}_bloc.dart';\n\nsealed class ${stateClass} extends Equatable {\n  const ${stateClass}();\n\n  @override\n  List<Object?> get props => [];\n}\n\nclass ${initialStateClass} extends ${stateClass} {\n  const ${initialStateClass}();\n}\n\nclass ${loadingStateClass} extends ${stateClass} {\n  const ${loadingStateClass}();\n}\n\nclass ${successStateClass} extends ${stateClass} {\n  final List<${entityClass}> items;\n\n  const ${successStateClass}(this.items);\n\n  @override\n  List<Object?> get props => [items];\n}\n\nclass ${failureStateClass} extends ${stateClass} {\n  final String message;\n\n  const ${failureStateClass}(this.message);\n\n  @override\n  List<Object?> get props => [message];\n}\n`,
    [`lib/src/features/${module}/di/${module}_dependency.dart`]: `import '../../../configs/injector/injector_conf.dart';\nimport '../data/datasources/${module}_local_datasource.dart';\nimport '../data/datasources/${module}_remote_datasource.dart';\nimport '../data/repositories/${module}_repository_impl.dart';\nimport '../domain/usecases/fetch_${module}_items_usecase.dart';\nimport '../presentation/bloc/${module}/${module}_bloc.dart';\n\nclass ${dependencyClass} {\n  ${dependencyClass}._();\n\n  static void init() {\n    if (!getIt.isRegistered<${blocClass}>()) {\n      getIt.registerFactory(\n        () => ${blocClass}(getIt<${fetchUseCase}>()),\n      );\n    }\n\n    if (!getIt.isRegistered<${fetchUseCase}>()) {\n      getIt.registerLazySingleton(\n        () => ${fetchUseCase}(getIt<${repositoryImplClass}>()),\n      );\n    }\n\n    if (!getIt.isRegistered<${repositoryImplClass}>()) {\n      getIt.registerLazySingleton(\n        () => ${repositoryImplClass}(\n          getIt<${remoteDataSourceImplClass}>(),\n          getIt<${localDataSourceImplClass}>(),\n        ),\n      );\n    }\n\n    if (!getIt.isRegistered<${remoteDataSourceImplClass}>()) {\n      getIt.registerLazySingleton(() => ${remoteDataSourceImplClass}());\n    }\n\n    if (!getIt.isRegistered<${localDataSourceImplClass}>()) {\n      getIt.registerLazySingleton(() => ${localDataSourceImplClass}());\n    }\n  }\n}\n`,
  };
}

const uniquePages = new Map();
for (const mapping of mappings) {
  if (!uniquePages.has(mapping.pageFile)) {
    uniquePages.set(mapping.pageFile, mapping.pageClass);
  }
}

const appRoutePathFile = path.join(ROOT, 'lib', 'src', 'routes', 'app_route_path.dart');
const appRouteConfFile = path.join(ROOT, 'lib', 'src', 'routes', 'app_route_conf.dart');
const routesBarrelFile = path.join(ROOT, 'lib', 'src', 'routes', 'routes.dart');

fs.writeFileSync(appRoutePathFile, buildAppRoutePathContent(), 'utf8');
fs.writeFileSync(appRouteConfFile, buildAppRouteConfContent(), 'utf8');
fs.writeFileSync(routesBarrelFile, buildRoutesBarrelContent(), 'utf8');

let createdPages = 0;
let updatedLegacyPages = 0;
let keptExistingPages = 0;

for (const [pageFile, className] of uniquePages.entries()) {
  const absolutePath = path.join(ROOT, pageFile);
  ensureParentDirectory(absolutePath);

  if (fs.existsSync(absolutePath)) {
    const currentContent = fs.readFileSync(absolutePath, 'utf8');
    if (isLegacySkeletonPage(currentContent, className)) {
      fs.writeFileSync(
        absolutePath,
        makeStandardSkeletonPageContent(className),
        'utf8',
      );
      updatedLegacyPages += 1;
    } else {
      keptExistingPages += 1;
    }
    continue;
  }

  fs.writeFileSync(absolutePath, makeStandardSkeletonPageContent(className), 'utf8');
  createdPages += 1;
}

let createdModuleFiles = 0;
let keptModuleFiles = 0;

for (const module of MODULES_TO_BOOTSTRAP) {
  const files = buildFeatureScaffoldFiles(module);
  for (const [relativeFile, content] of Object.entries(files)) {
    const absolutePath = path.join(ROOT, relativeFile);
    if (fs.existsSync(absolutePath)) {
      keptModuleFiles += 1;
      continue;
    }

    ensureParentDirectory(absolutePath);
    fs.writeFileSync(absolutePath, content, 'utf8');
    createdModuleFiles += 1;
  }
}

console.log(`Updated: ${path.relative(ROOT, appRoutePathFile)}`);
console.log(`Updated: ${path.relative(ROOT, appRouteConfFile)}`);
console.log(`Updated: ${path.relative(ROOT, routesBarrelFile)}`);
console.log(`Skeleton pages created: ${createdPages}`);
console.log(`Skeleton pages upgraded from legacy template: ${updatedLegacyPages}`);
console.log(`Skeleton pages already existed: ${keptExistingPages}`);
console.log(`Total unique page files in mapping: ${uniquePages.size}`);
console.log(`Feature scaffold files created: ${createdModuleFiles}`);
console.log(`Feature scaffold files already existed: ${keptModuleFiles}`);