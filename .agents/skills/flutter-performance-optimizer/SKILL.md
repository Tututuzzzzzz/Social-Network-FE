---
name: flutter-performance-optimizer
description: Tối ưu hiệu năng frontend Flutter cho repository này. Luôn dùng skill này khi user đề cập tối ưu performance, app bị lag hoặc giật, giảm rebuild, tối ưu ListView, tối ưu animation, tối ưu hình ảnh, kiểm tra hiệu năng màn hình, hoặc yêu cầu code Flutter chạy mượt hơn, kể cả khi user không nhắc Flutter DevTools.
---

# Flutter Performance Optimizer

## Mục tiêu
Giúp agent phân tích đúng bottleneck hiệu năng trong Flutter và tối ưu theo số liệu, không đoán mò.

Kết quả mong muốn:
- giảm jank và dropped frame
- giảm rebuild không cần thiết
- giảm thời gian build/raster frame
- giảm peak memory và rò rỉ tài nguyên
- giữ nguyên hành vi nghiệp vụ

## Bối cảnh cấu trúc dự án hiện tại
Khi sửa code hiệu năng trong repository này, luôn bám đúng cấu trúc đang có:
- feature-first theo từng module: auth, chat, friend, home, message, post, profile, reels
- mỗi feature theo tầng data, domain, presentation, di
- điều hướng tập trung ở lib/src/routes
- dependency injection qua getIt trong lib/src/configs/injector
- state management chính là flutter_bloc; riêng friend có phần legacy ChangeNotifier/Provider

Rule bắt buộc:
- tối ưu đúng chỗ, đúng feature, đúng tầng
- không tạo kiến trúc mới song song
- không refactor diện rộng ngoài phạm vi bottleneck đang xử lý

## Khi nào phải kích hoạt skill này
Kích hoạt ngay khi user có các ý như:
- tối ưu performance
- app bị lag hoặc giật
- giảm rebuild
- tối ưu ListView
- tối ưu animation
- tối ưu hình ảnh
- kiểm tra hiệu năng màn hình này
- làm code Flutter chạy mượt hơn

Kể cả khi user mô tả gián tiếp như "màn hình scroll bị khựng", "mở trang này tốn RAM", "animation không mượt", vẫn phải bật skill này.

## Nguyên tắc vận hành
- Luôn đo trước khi sửa và đo lại sau khi sửa.
- Ưu tiên thay đổi nhỏ, tác động lớn.
- Không tối ưu mù; mỗi thay đổi phải gắn với một giả thuyết bottleneck.
- Không thêm dependency mới nếu chưa thật sự cần thiết.
- Không tạo workspace benchmark hoặc evals mới nếu user không yêu cầu.

## Quy trình bắt buộc

### Bước 1: Chốt phạm vi và baseline
1. Xác định đúng màn hình, route, feature, và luồng thao tác gây lag.
2. Thu baseline bằng profile mode và Flutter DevTools.
3. Ghi lại các số liệu trước khi sửa.

Tối thiểu phải có baseline:
- thời gian frame build và raster (đặc biệt p95)
- số frame vượt ngưỡng (jank)
- CPU hotspot theo timeline
- memory tăng theo thời gian và GC spike
- điểm có rebuild dày đặc

Ngưỡng tham chiếu:
- 60Hz: frame budget ~16ms
- 120Hz: frame budget ~8ms

### Bước 2: Profiling bằng Flutter DevTools
Dùng DevTools để định vị bottleneck thật sự:
- Performance view: kiểm tra frame chart, timeline events, shader/raster spikes
- CPU Profiler: tìm hàm chạy nặng trên UI isolate
- Memory view: theo dõi heap growth, GC, object retaining
- Flutter Inspector: bật theo dõi repaint/rebuild để tìm vùng bị rebuild thừa

Nếu có thể tái hiện ổn định, đo trên cùng kịch bản thao tác trước và sau sửa.

### Bước 3: Phân loại bottleneck
Map bottleneck vào một hoặc nhiều nhóm sau:
1. Rebuild quá mức
2. List hoặc scroll rendering nặng
3. Hình ảnh decode hoặc cache chưa tối ưu
4. Async work chặn UI isolate
5. Animation gây layout/raster tốn kém
6. Memory leak hoặc giữ tài nguyên sai vòng đời

### Bước 4: Áp dụng tối ưu theo nhóm

#### 4.1 Tối ưu rebuild
- Dùng const constructor tối đa nơi có thể.
- Tách widget lớn thành widget nhỏ để giới hạn vùng rebuild.
- Tránh đặt setState ở node cha quá rộng.
- Với Bloc: ưu tiên BlocSelector hoặc buildWhen để chỉ rebuild phần cần thiết.
- Dùng ValueListenableBuilder hoặc selector pattern cho state cục bộ.
- Dùng Key đúng chỗ để giữ state và tránh rebuild sai.

#### 4.2 Tối ưu ListView và virtualization
- Dùng ListView.builder hoặc GridView.builder thay cho children tĩnh dài.
- Ưu tiên SliverList/CustomScrollView khi có nhiều section.
- Khai báo itemExtent hoặc prototypeItem khi kích thước item ổn định.
- Dùng pagination/lazy loading, không tải toàn bộ danh sách một lần.
- Tránh widget item quá nặng; tách phần thay đổi nhanh ra khỏi phần tĩnh.
- Cân nhắc cacheExtent theo thực tế, tránh tăng quá cao gây tốn RAM.

#### 4.3 Tối ưu hình ảnh và image cache
- Không render ảnh gốc quá lớn so với kích thước hiển thị.
- Đặt width/height rõ ràng để giảm layout shift và decode không cần thiết.
- Dùng cacheWidth/cacheHeight hoặc ResizeImage khi phù hợp.
- Dùng precacheImage cho ảnh chuẩn bị xuất hiện ngay sau đó.
- Tránh tải đồng thời quá nhiều ảnh lớn ở cùng frame.
- Ưu tiên định dạng nén tốt (webp/jpg hợp lý) thay vì ảnh quá nặng.

#### 4.4 Tối ưu async work
- Không parse JSON nặng hoặc xử lý dữ liệu lớn trực tiếp trên UI isolate.
- Dùng isolate/compute cho tác vụ CPU-bound.
- Debounce hoặc throttle các thao tác search/filter theo input.
- Hủy request/subscription cũ khi không còn cần.
- Tránh chuỗi await tuần tự nếu có thể chạy song song an toàn.

#### 4.5 Tối ưu animation
- Dùng AnimatedBuilder với child để tránh rebuild subtree không đổi.
- Ưu tiên transform/opacity hợp lý thay vì animation gây relayout sâu.
- Hạn chế số animation chạy đồng thời ở cùng màn hình.
- Dùng RepaintBoundary đúng chỗ cho vùng animation độc lập.
- Dispose AnimationController đầy đủ.

#### 4.6 Tối ưu memory và tránh leak
- Dispose đầy đủ: AnimationController, ScrollController, TextEditingController, FocusNode, StreamSubscription, Timer.
- Không giữ BuildContext hoặc reference widget state quá vòng đời.
- Kiểm tra luồng async có mounted guard trước khi cập nhật UI.
- Tránh cache không giới hạn hoặc giữ object lớn quá lâu.

### Bước 5: Đo lại và xác nhận hiệu quả
Bắt buộc đo lại cùng kịch bản baseline và so sánh:
- p95 frame time trước/sau
- số jank frame trước/sau
- CPU hotspot đã giảm chưa
- memory peak và xu hướng heap sau thao tác lặp

Nếu không có cải thiện rõ, rollback thay đổi không hiệu quả và thử giả thuyết khác.

## Checklist review trước khi sửa
- Đã xác định đúng màn hình và thao tác gây lag.
- Đã có baseline bằng DevTools.
- Đã nêu rõ giả thuyết bottleneck.
- Đã khoanh phạm vi file cần sửa theo đúng feature/tầng.
- Đã xác định rủi ro ảnh hưởng hành vi nghiệp vụ.

## Checklist review sau khi sửa
- Có số liệu trước/sau cho ít nhất frame và jank.
- Không phát sinh regression nghiệp vụ.
- Không thêm rebuild thừa ở vùng khác.
- Không tạo memory leak mới (dispose đầy đủ).
- Cấu trúc code vẫn đúng chuẩn repository.
- Chỉ thay đổi trong phạm vi cần thiết.

## Mẫu output bắt buộc khi agent trả kết quả
Agent nên trả theo format sau:

1. Phạm vi và triệu chứng
- màn hình/feature liên quan
- dấu hiệu lag user gặp

2. Baseline trước tối ưu
- frame, jank, memory, hotspot chính

3. Bottleneck đã xác định
- nguyên nhân gốc theo từng nhóm

4. Thay đổi đã áp dụng
- danh sách thay đổi chính và lý do

5. Kết quả sau tối ưu
- so sánh trước/sau bằng số liệu

6. Rủi ro còn lại và đề xuất tiếp theo
- các điểm cần theo dõi thêm

## Điều không được làm
- Không tối ưu chỉ dựa cảm giác khi chưa có baseline.
- Không refactor toàn bộ codebase khi bottleneck chỉ ở một màn hình.
- Không thêm package mới chỉ để thử nghiệm nếu chưa có nhu cầu rõ ràng.
- Không giữ thay đổi nếu số liệu sau tối ưu không cải thiện.

## Ưu tiên thực thi
Trong repository này, ưu tiên đúng bottleneck, đúng cấu trúc, đúng số liệu trước/sau hơn là tối ưu tràn lan.