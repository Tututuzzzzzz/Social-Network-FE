---
name: flutter-structure
description: Ép agent tuân thủ code structure hiện tại của dự án Flutter này khi tạo/chỉnh sửa UI. Luôn dùng skill này khi người dùng yêu cầu tạo page/screen/widget/flow mới, thêm route, refactor giao diện, hoặc hỏi "nên đặt code ở tầng nào" trong repo này, kể cả khi người dùng không nói rõ "theo cấu trúc cũ".
---

# Flutter Structure 

## Mục tiêu
Giữ mọi thay đổi UI bám sát cấu trúc đang có của dự án, để khi tạo màn hình mới thì agent biết chính xác:
- code nằm ở thư mục nào
- khi nào cần thêm bloc/domain/data/di
- cần cập nhật route và dependency ở đâu
- khi nào dùng widget shared, khi nào giữ trong feature
- tầng nào được phép chứa loại logic nào

## Bối cảnh cấu trúc hiện tại (đã chốt theo codebase)

### 1) Cấu trúc tổng thể theo feature
Mỗi feature đang theo mô hình:
- data
- di
- domain
- presentation

Các feature hiện có:
- auth
- chat
- friend
- home
- message
- post
- profile
- reels

## Vai trò từng tầng (bắt buộc tuân thủ)

### 1) presentation
Mục đích:
- render UI và xử lý tương tác người dùng.

Nên chứa:
- pages/screens, widgets, bloc/cubit/state/event.
- mapping dữ liệu từ domain model sang view model đơn giản để hiển thị.

Không chứa:
- gọi API trực tiếp.
- truy cập DB/storage/network trực tiếp.
- business rule cốt lõi (ví dụ policy nghiệp vụ, validation nghiệp vụ phức tạp).

Đường dẫn chuẩn:
- `lib/src/features/<feature>/presentation/pages/`
- `lib/src/features/<feature>/presentation/widgets/`
- `lib/src/features/<feature>/presentation/bloc/<scope>/`

### 2) domain
Mục đích:
- định nghĩa nghiệp vụ cốt lõi độc lập framework và hạ tầng.

Nên chứa:
- entities/value objects.
- use cases (mỗi use case đại diện 1 hành vi nghiệp vụ).
- repository contracts (abstract/interface).

Không chứa:
- import thư viện hạ tầng (dio/http/hive/firebase/retrofit...).
- model parse JSON hoặc DTO network.
- widget/bloc/context.

Đường dẫn chuẩn:
- `lib/src/features/<feature>/domain/entities/`
- `lib/src/features/<feature>/domain/usecases/`
- `lib/src/features/<feature>/domain/repositories/`

### 3) data
Mục đích:
- hiện thực truy cập dữ liệu và chuyển đổi dữ liệu vào/ra domain.

Nên chứa:
- datasource (remote/local).
- models/DTO + mapping.
- repository implementations (implements domain repository).

Không chứa:
- widget/bloc.
- phụ thuộc trực tiếp vào BuildContext.

Đường dẫn chuẩn:
- `lib/src/features/<feature>/data/datasources/`
- `lib/src/features/<feature>/data/models/`
- `lib/src/features/<feature>/data/repositories/`

### 4) di
Mục đích:
- wiring dependency cho feature theo thứ tự data -> domain usecase -> presentation bloc.

Nên chứa:
- đăng ký datasource, repository impl, usecase, bloc.

Không chứa:
- business logic.
- xử lý UI.

Đường dẫn chuẩn:
- `lib/src/features/<feature>/di/*dependency.dart` (hoặc `*depedency.dart` theo hiện trạng code).

## Luồng phụ thuộc chuẩn giữa các tầng
Luồng bắt buộc (một chiều):
- `presentation -> domain`
- `data -> domain`
- `di` được phép biết tất cả để wiring.

Các chiều không được phép:
- `domain -> data`
- `domain -> presentation`
- `presentation -> data` (trừ trường hợp legacy đã tồn tại và chỉ khi user yêu cầu giữ nguyên).

Mẫu nối luồng chuẩn khi có logic thật:
- `Page/Widget -> Bloc -> UseCase -> Repository (abstract) -> RepositoryImpl -> DataSource`.

Nếu chỉ làm UI tĩnh/mock:
- chỉ dùng `presentation` (+ route nếu cần), không tạo `domain/data` thừa.

### 2) Routing hiện tại
- Định nghĩa path/name tập trung ở lib/src/routes/app_route_path.dart
- Khai báo GoRoute ở lib/src/routes/app_route_conf.dart
- Export page dùng cho route ở lib/src/routes/routes.dart
- App shell bottom nav dùng lib/src/routes/app_shell_page.dart

### 3) Dependency injection hiện tại
- Mỗi feature có file DI riêng ở lib/src/features/<feature>/di/*dependency.dart (hoặc *depedency.dart theo code hiện có)
- Tổng hợp export DI ở lib/src/configs/injector/injector.dart
- Gọi init dependency trong lib/src/configs/injector/injector_conf.dart

Lưu ý:
- Codebase hiện có tên class AuthDepedency/PostDepedency (chính tả theo hiện trạng).
- Không tự động "sửa chính tả toàn bộ" nếu user không yêu cầu refactor.

### 4) State management
- Mặc định ưu tiên flutter_bloc cho màn hình/feature mới.
- Riêng friend đang có luồng ChangeNotifier + Provider, chỉ theo pattern này khi chỉnh sửa đúng khu vực friend legacy.

### 5) i18n
- Chuỗi hiển thị ưu tiên dùng context.l10n
- Key nằm ở:
  - lib/src/l10n/app_vi.arb
  - lib/src/l10n/app_en.arb
- Extension truy cập l10n: lib/src/core/l10n/l10n.dart

## Khi nào dùng skill này
Dùng ngay khi prompt có các ý sau:
- "tạo màn hình mới", "tạo giao diện mới", "thêm page/screen/widget"
- "làm flow UI"
- "thêm route cho màn hình"
- "code theo cấu trúc hiện tại"
- "đặt đúng chỗ file"
- "refactor UI nhưng không phá kiến trúc"
- "nên viết ở tầng domain hay data"
- "chỗ này để ở bloc hay usecase"

## Quy trình bắt buộc khi thực thi

### Bước 1: Xác định feature đích
Ưu tiên map theo domain nghiệp vụ user mô tả:
- đăng nhập/đăng ký -> auth
- feed/bài viết -> post hoặc home (xem route hiện có)
- chat/tin nhắn -> chat hoặc message
- hồ sơ -> profile
- reels/story -> reels
- bạn bè/lời mời -> friend

Nếu có 2 feature đều hợp lý:
- chọn feature đã chứa màn hình gần nhất về nghiệp vụ
- nêu rõ lý do chọn trong phần tóm tắt thay đổi

### Bước 2: Chốt tầng trước khi chốt file
Phải quyết định theo bảng sau:

| Loại thay đổi | Viết ở đâu | Không viết ở đâu |
|---|---|---|
| Layout UI, animation, điều hướng local widget | `presentation/pages` hoặc `presentation/widgets` | `domain`, `data` |
| Quản lý state màn hình, loading/error/success, submit form | `presentation/bloc` | `data` |
| Nghiệp vụ cốt lõi (ví dụ validate điều kiện nghiệp vụ, quyết định luồng) | `domain/usecases` (+ `domain/entities` nếu cần) | `presentation`, `data/models` |
| Định nghĩa contract repository | `domain/repositories` | `presentation` |
| Gọi API/local storage, parse JSON, map DTO | `data/datasources`, `data/models` | `presentation`, `domain` |
| Hiện thực repository theo contract domain | `data/repositories` | `presentation` |
| Khởi tạo/wiring dependency | `di/` + injector tổng | `domain`, `presentation/pages` |
| Widget dùng chung nhiều feature | `lib/src/widgets/` | feature presentation/widgets |

### Bước 3: Chốt vị trí file cụ thể
Sau khi xác định tầng, đặt file theo ma trận chuẩn:
- Page/screen mới: `lib/src/features/<feature>/presentation/pages/`
- Widget chỉ dùng trong feature: `lib/src/features/<feature>/presentation/widgets/`
- Widget dùng chung nhiều feature: `lib/src/widgets/`
- Bloc/State/Event: `lib/src/features/<feature>/presentation/bloc/<scope>/`
- Entity/UseCase/Repository abstract: `lib/src/features/<feature>/domain/`
- Datasource/Model/Repository impl: `lib/src/features/<feature>/data/`
- DI: `lib/src/features/<feature>/di/`

### Bước 4: Chỉ thêm domain/data khi thật sự cần
Nếu user chỉ yêu cầu UI tĩnh hoặc mock UI:
- chỉ sửa `presentation` (+ route nếu cần).
- không tạo datasource/repository/usecase thừa.

Nếu UI cần dữ liệu thật hoặc hành vi nghiệp vụ:
- nối theo chuỗi đầy đủ: `Presentation -> UseCase -> Repository (abstract) -> RepositoryImpl -> DataSource`.

### Bước 5: Tích hợp route đầy đủ khi có màn hình mới
Khi page cần truy cập từ điều hướng:
- thêm enum route vào lib/src/routes/app_route_path.dart
- thêm export page vào lib/src/routes/routes.dart (nếu flow route hiện tại dùng file này)
- thêm GoRoute trong lib/src/routes/app_route_conf.dart
- nếu màn hình cần bloc, bọc BlocProvider tại route builder theo pattern hiện có

### Bước 6: Tích hợp DI đầy đủ khi có logic mới
Nếu có bloc/usecase/repository/datasource mới:
- đăng ký trong file DI của feature tương ứng
- đảm bảo dependency đó đã được export trong lib/src/configs/injector/injector.dart nếu pattern hiện tại cần
- đảm bảo hàm init của feature được gọi trong lib/src/configs/injector/injector_conf.dart

### Bước 7: Chuẩn hóa text hiển thị
- Tránh hardcode text cho UI chính
- Thêm key vào app_vi.arb và app_en.arb khi cần
- Dùng context.l10n trong widget

### Bước 8: Kiểm tra nhất quán trước khi kết thúc
Checklist bắt buộc:
- file mới đặt đúng feature và đúng tầng
- route không bị thiếu path/name/builder
- DI không thiếu registration
- không đặt business logic cốt lõi ở bloc/widget
- không gọi API trực tiếp từ presentation
- không tạo kiến trúc mới ngoài style hiện tại
- không chạm vào các phần không liên quan

## Quy tắc đặt tên
- File: snake_case
- Class: PascalCase
- Widget màn hình: hậu tố Page hoặc Screen theo ngữ cảnh file hiện hữu
- Bloc: <Feature>Bloc
- Params/usecase: theo pattern đang dùng trong feature đó

## Điều không được làm
- Không tạo workspace benchmark/evals khi user không yêu cầu
- Không tạo một "kiến trúc mới" song song kiến trúc hiện tại
- Không đổi hàng loạt naming cũ chỉ vì muốn đẹp hơn
- Không chuyển state management sang thư viện khác nếu chưa có yêu cầu rõ
- Không đẩy logic nghiệp vụ xuống UI chỉ để code nhanh
- Không đặt parsing DTO/JSON vào domain

## Mẫu đầu ra khuyến nghị khi trả lời user
Trước khi code, luôn nêu ngắn gọn:
- Feature sẽ chỉnh
- Tầng sẽ chạm (presentation/domain/data/di) và lý do
- Danh sách file sẽ tạo/sửa
- Route/DI có cần cập nhật không

Sau khi code, tóm tắt:
- Đã thêm gì
- Vì sao đặt ở vị trí đó
- Phần nào ở presentation, phần nào ở domain/data
- Màn hình đi vào bằng route nào
- Còn thiếu gì (nếu có)

## Ưu tiên thực thi
Trong repo này, ưu tiên đúng cấu trúc hơn tốc độ sinh code. Nếu xung đột giữa "code nhanh" và "đặt đúng chỗ", luôn chọn đặt đúng chỗ.

# Global Shared Structure (ngoài feature)

## 1. lib/src/core

Mục đích:

* chứa các thành phần dùng chung toàn app, độc lập feature cụ thể.

Nguyên tắc:

* không chứa business logic riêng của từng feature.
* mọi feature đều có thể reuse.

---

### core/api

Mục đích:

* cấu hình API client dùng chung toàn app.

Ví dụ:

* Dio client
* interceptors
* base request config
* refresh token handler

Không chứa:

* API implementation riêng của feature.

---

### core/blocs

Mục đích:

* state management cấp global.

Ví dụ hiện có:

* theme
* translate

Dùng khi:

* state ảnh hưởng toàn app.

Không dùng cho:

* state riêng màn hình/feature.

---

### core/cache

Mục đích:

* abstraction cho local storage.

Ví dụ:

* hive_local_storage.dart
* secure_local_storage.dart

Dùng khi:

* feature cần lưu local data.

Không gọi trực tiếp từ presentation.

Flow đúng:

* `presentation -> usecase -> repository -> cache service`

---

### core/constants

Mục đích:

* constants dùng chung toàn app.

Ví dụ:

* error message
* locale constants

Không chứa:

* business rules động.

---

### core/errors

Mục đích:

* centralized exception/failure handling.

Ví dụ:

* exceptions.dart
* failures.dart

Dùng để:

* chuẩn hóa error giữa data/domain/presentation.

---

### core/extensions

Mục đích:

* extension methods dùng chung.

Ví dụ:

* string validator
* responsive helpers

Không chứa:

* business logic feature-specific.

---

### core/l10n

Mục đích:

* localization helpers/extensions.

Ví dụ:

* context.l10n access

---

### core/network

Mục đích:

* network state helpers.

Ví dụ:

* network_checker.dart

---

### core/realtime

Mục đích:

* websocket/realtime services dùng chung.

Ví dụ:

* realtime_socket_service.dart

---

### core/usecases

Mục đích:

* base usecase abstraction dùng chung.

Ví dụ:

* abstract UseCase class

---

### core/utils

Mục đích:

* utility helpers dùng chung.

Ví dụ:

* logger
* regex validator
* url normalizer

Không chứa:

* logic nghiệp vụ của feature.

---

## 2. lib/src/configs

### configs/adapter

Mục đích:

* cấu hình adapter/integration layer toàn app.

Ví dụ:

* adapter cho package ngoài
* environment bridge
* external SDK wrapper config

Không chứa:

* feature business logic.

---

### configs/injector

Mục đích:

* dependency injection bootstrap toàn app.

File hiện có:

* injector.dart
* injector_conf.dart

Vai trò:

* aggregate toàn bộ dependency registration.

---

## 3. lib/src/routes

### app_route_path.dart

Mục đích:

* định nghĩa route path/name constants.

---

### app_route_conf.dart

Mục đích:

* cấu hình GoRouter.

---

### app_shell_page.dart

Mục đích:

* shell layout global (bottom nav/container pages).

---

### routes.dart

Mục đích:

* export route pages/screens.

---

## 4. lib/src/widgets

Mục đích:

* reusable widgets dùng chung nhiều feature.

Ví dụ hiện có:

* custom_button
* snackbar_widget
* feature_page_scaffold

Nguyên tắc:

* nếu widget được reuse >= 2 feature -> move vào đây.
* nếu chỉ dùng trong 1 feature -> giữ trong feature/presentation/widgets.

---

## 5. lib/src/l10n

Mục đích:

* localization resources.

File:

* app_vi.arb
* app_en.arb

Nguyên tắc:

* UI text chính không hardcode.
* thêm key mới khi tạo UI mới.

---

## Quy tắc phân biệt core vs feature

Dùng `core` khi:

* reusable toàn app
* generic
* không thuộc nghiệp vụ cụ thể

Dùng `feature` khi:

* logic/domain thuộc nghiệp vụ cụ thể
* state riêng feature
* UI riêng feature

---

## Quy tắc phân biệt widgets vs feature widgets

Đặt ở `lib/src/widgets` nếu:

* nhiều feature dùng lại

Đặt ở `feature/presentation/widgets` nếu:

* chỉ phục vụ feature đó

---

## Quy tắc dependency toàn project

Feature được phép dùng:

* core/*
* widgets/*
* routes/*
* configs/*

Core không được import ngược feature.

---

## Bổ sung quy tắc kiến trúc tổng thể

### Không được bypass architecture

Không được:

* gọi API trực tiếp từ widget/page
* đọc Hive/SecureStorage trực tiếp từ bloc
* parse JSON trong presentation
* nhét business logic vào widget

Luôn đi theo flow:

* `presentation -> domain -> data`

---

### Khi tạo feature mới

Mặc định structure:

* `data/`
* `domain/`
* `presentation/`
* `di/`

---

### Khi tạo reusable component

Nếu component:

* chỉ dùng trong 1 feature -> giữ trong feature
* dùng toàn app -> move sang `lib/src/widgets`

Không duplicate widget giống nhau ở nhiều feature.

---

### Khi thêm logic global

Logic ảnh hưởng toàn app:

* theme
* locale
* auth session
* connectivity

=> ưu tiên đặt trong `core/blocs` hoặc `core/services`

Không đặt trong feature riêng lẻ.

---

### Khi thêm service mới

Nếu service generic:

* đặt trong `core`

Ví dụ:

* analytics
* logger
* socket manager
* connectivity

Nếu service chỉ phục vụ 1 feature:

* đặt trong feature/data

---

### Quy tắc import

Ưu tiên import theo layer đúng chiều:

Đúng:

* `presentation -> domain`
* `data -> domain`

Sai:

* `domain -> presentation`
* `domain -> data`

---

### Quy tắc mở rộng codebase

Khi thêm code mới:

* follow naming hiện tại
* follow folder hiện tại
* không invent architecture mới
* không mix nhiều state management nếu không cần

Consistency ưu tiên hơn "clean architecture textbook".

---

### Quy tắc cuối cùng

Nếu không chắc nên đặt code ở đâu:

* ưu tiên vị trí giống feature hiện có nhất
* giữ consistency với codebase hiện tại thay vì tự redesign structure
