---
name: flutter-state-management
description: Thiết kế và refactor state management cho frontend Flutter trong repository này. Luôn dùng skill này khi user yêu cầu tạo state management, dùng Riverpod, dùng Bloc/Cubit, quản lý trạng thái màn hình, loading/error/success state, refactor setState, tách logic khỏi widget, quản lý auth state, hoặc quản lý feed/post/comment state.
---

# Flutter State Management 

## Mục tiêu
Giúp agent tổ chức state management rõ ràng, dễ mở rộng, đúng cấu trúc dự án hiện có và giảm logic dồn trong UI.

Kết quả mong muốn:
- UI chỉ làm nhiệm vụ render và xử lý interaction cơ bản
- state và business logic nằm đúng tầng, đúng feature
- state immutable, dễ debug, dễ test
- có luồng loading, error, data rõ ràng
- tránh global mutable state và side effect khó kiểm soát

## Bối cảnh cấu trúc hiện tại của repository
Luôn bám theo hiện trạng codebase này:
- kiến trúc feature-first: auth, chat, friend, home, message, post, profile, reels
- mỗi feature có data, domain, presentation, di
- presentation hiện dùng pages thống nhất
- state management chính là flutter_bloc (mẫu event-state)
- friend là vùng legacy dùng ChangeNotifier + Provider
- DI qua getIt trong lib/src/configs/injector
- route nằm ở lib/src/routes

Hệ quả bắt buộc:
- mặc định ưu tiên Bloc/Cubit cho code mới
- chỉ giữ Provider/ChangeNotifier khi sửa vùng friend legacy hoặc khi user yêu cầu giữ tương thích
- Riverpod chỉ dùng khi user yêu cầu rõ hoặc có phạm vi migration rõ ràng

## Khi nào phải kích hoạt skill này
Kích hoạt ngay khi user nhắc hoặc ám chỉ:
- tạo state management
- dùng Riverpod
- dùng Bloc/Cubit
- quản lý trạng thái màn hình
- loading/error/success state
- refactor setState
- tách logic khỏi widget
- quản lý auth state
- quản lý feed/post/comment state

Các mô tả gián tiếp vẫn kích hoạt:
- màn hình quá nhiều setState
- code page quá dài vì chứa logic nghiệp vụ
- khó quản lý loading/error khi gọi API
- state bị chia nhỏ, khó đồng bộ

## Nguyên tắc lựa chọn state management

### 1) Ưu tiên theo cấu trúc hiện có
- Trong feature đang dùng Bloc, tiếp tục dùng Bloc hoặc Cubit.
- Trong friend legacy, có thể giữ ChangeNotifier nếu chỉ sửa nhỏ.
- Không trộn nhiều framework state management trong cùng một flow nếu không bắt buộc.

### 2) Chọn Bloc hay Cubit
- Chọn Bloc khi luồng có nhiều event, nhiều nhánh nghiệp vụ, cần audit event rõ.
- Chọn Cubit khi state đơn giản hơn, hành vi tuyến tính, ít event type.
- Nếu feature đã có Bloc ổn định, không chuyển sang Cubit chỉ vì sở thích.

### 3) Khi user yêu cầu Riverpod
- Vẫn kích hoạt skill này.
- Đề xuất phương án ít rủi ro: áp dụng theo feature mới hoặc module tách biệt.
- Tránh migration toàn bộ repo trong một lần trừ khi user yêu cầu rõ.
- Giữ nguyên nguyên tắc tách UI/state/business logic như với Bloc.

## Quy trình bắt buộc khi thực thi

### Bước 1: Khoanh phạm vi state
Xác định rõ:
- màn hình/feature nào cần quản lý state
- state nào là UI local state, state nào là domain state
- nguồn dữ liệu: cache, API, realtime, local form input

### Bước 2: Tách lớp trách nhiệm
Tuân thủ phân tách:
- UI (Widget/Page): render và gửi action
- State layer (Bloc/Cubit/Provider): điều phối trạng thái
- Domain layer (UseCase): nghiệp vụ
- Data layer (Repository/Datasource): truy xuất dữ liệu

Không để:
- parse dữ liệu phức tạp trong Widget
- gọi trực tiếp datasource từ Widget
- nhồi logic nghiệp vụ vào onPressed/onChanged dài

### Bước 3: Thiết kế state immutable
Quy tắc state:
- dùng class immutable (final field, copyWith nếu cần)
- state phải biểu diễn rõ vòng đời dữ liệu
- tránh sửa trực tiếp object state cũ

Mẫu trạng thái nên có:
- initial hoặc idle
- loading
- success/data loaded
- failure/error
- optional: refreshing, pagination loading, empty

### Bước 4: Tổ chức theo feature
Đặt code đúng vị trí:
- Bloc/Cubit/State/Event trong lib/src/features/<feature>/presentation/bloc/<scope>
- Page trong lib/src/features/<feature>/presentation/pages
- UseCase trong lib/src/features/<feature>/domain/usecases
- Repository abstract trong domain/repositories
- Repository impl và datasource trong data/
- Đăng ký DI ở lib/src/features/<feature>/di

Nếu thêm state logic mới, luôn kiểm tra:
- đã đăng ký getIt đầy đủ chưa
- route builder đã bọc provider phù hợp chưa (nếu màn hình cần)

### Bước 5: Chuẩn hóa xử lý loading/error/data
Bắt buộc có chiến lược thống nhất:
- loading: hiển thị progress hoặc skeleton đúng ngữ cảnh
- success: render data state ổn định
- empty: hiển thị trạng thái trống rõ ràng
- error: thông báo lỗi + cho phép retry khi hợp lý

Không được:
- nuốt lỗi im lặng
- vừa emit success vừa giữ cờ error mơ hồ
- để UI phải tự đoán trạng thái

### Bước 6: Refactor setState an toàn
Khi user yêu cầu refactor setState:
- chỉ giữ setState cho UI local state nhỏ và tạm thời (ví dụ toggle hiển thị)
- chuyển network/business state sang Bloc/Cubit/Provider theo feature
- tách dần theo phạm vi, tránh big-bang refactor

### Bước 7: Tránh anti-pattern state
Luôn tránh:
- global mutable state dùng chung không kiểm soát
- singleton chứa state thay đổi tùy tiện
- logic nghiệp vụ trong Widget
- side effects rải rác không qua state layer
- emit state không nhất quán thứ tự

## Mẫu xử lý theo nhóm bài toán

### Auth state
- state cho sign-in status, login loading, login failure, logout flow
- token/session handling không nằm trong widget
- route guard hoặc redirect bám theo auth state rõ ràng

### Feed/Post/Comment state
- tách state cho load list, create/update/delete action
- nếu có pagination, tách loading đầu trang và loading trang tiếp theo
- optimistic update chỉ dùng khi rollback rõ ràng khi lỗi
- comment state không làm bẩn toàn bộ feed state nếu không cần

## Checklist review state trước khi hoàn thành
- Đã chọn framework state management đúng với cấu trúc hiện có của feature.
- UI đã tách khỏi state/business logic đủ rõ.
- State là immutable, không mutate trực tiếp.
- Luồng loading/error/success (và empty nếu cần) đầy đủ.
- Không còn logic nghiệp vụ chính nằm trong Widget.
- Không có global mutable state mới được thêm.
- File được đặt đúng feature và đúng tầng (presentation/domain/data/di).
- DI registration đầy đủ cho bloc/cubit/provider/usecase/repository mới.
- Luồng retry/error message hoạt động đúng.
- Phạm vi thay đổi vừa đủ, không refactor lan rộng ngoài yêu cầu.

## Mẫu output bắt buộc khi agent trả kết quả
Agent nên trả theo format:

1. Phạm vi state
- feature/màn hình liên quan
- vấn đề hiện tại

2. Lựa chọn state management
- chọn Bloc/Cubit/Provider/Riverpod và lý do
- vì sao phù hợp với cấu trúc dự án

3. Thiết kế state
- danh sách state chính (loading/error/success/...)
- event/action tương ứng

4. Tách lớp logic
- phần nào ở UI
- phần nào ở state layer
- phần nào ở usecase/repository

5. Thay đổi đã áp dụng
- các file đã sửa/tạo và mục đích

6. Kiểm tra trước khi chốt
- đối chiếu checklist review state

## Điều không được làm
- Không tạo workspace benchmark/evals mới nếu user không yêu cầu.
- Không đổi toàn bộ framework state management của repo trong một lần.
- Không thêm state manager mới chỉ vì sở thích cá nhân.
- Không để Widget trở thành nơi chứa business logic chính.

## Ưu tiên thực thi
Trong repo này, ưu tiên nhất quán với kiến trúc hiện có và tính dễ bảo trì dài hạn hơn là áp dụng framework mới tràn lan.