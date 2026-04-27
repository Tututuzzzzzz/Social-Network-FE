---
name: frontend-design
description: Tạo giao diện Flutter production-grade với chất lượng thiết kế cao, mang tính thẩm mỹ mạnh và tránh cảm giác UI AI-generated generic. Sử dụng skill này khi người dùng yêu cầu xây dựng mobile app, tablet UI, dashboard, widget, screen hoặc design system bằng Flutter.
license: Custom Internal Use
---

Skill này hướng dẫn tạo ra giao diện Flutter độc đáo, có bản sắc thiết kế rõ ràng và đạt chất lượng production thay vì những UI mobile rập khuôn, generic hoặc “AI slop”.

Mục tiêu không chỉ là viết code Flutter chạy được, mà còn tạo ra trải nghiệm có cảm xúc, có định hướng nghệ thuật và có độ hoàn thiện cao như sản phẩm thật.

Người dùng có thể yêu cầu:
- tạo màn hình Flutter
- tạo component/widget
- tạo app mobile hoàn chỉnh
- tạo dashboard
- tạo onboarding
- tạo animation UI
- tạo design system
- tạo UI cho fintech, ecommerce, social app, productivity app, AI app...

Skill phải tạo ra:
- code Flutter thực tế và chạy được
- UI có chiều sâu thị giác
- trải nghiệm cao cấp
- animation mượt
- bố cục có chủ đích
- cảm giác như sản phẩm được thiết kế bởi senior product designer

------------------------------------------------------------------

# TƯ DUY THIẾT KẾ TRƯỚC KHI CODE

Trước khi viết code, phải xác định rõ định hướng thiết kế.

## 1. Hiểu mục đích sản phẩm

- App này giải quyết vấn đề gì?
- Ai là người dùng?
- Người dùng cần cảm thấy gì khi sử dụng?
- Trải nghiệm cần nhanh gọn, cao cấp, playful hay experimental?

## 2. Chọn aesthetic cực kỳ rõ ràng

KHÔNG tạo UI trung tính hoặc generic.

Phải chọn một hướng rõ ràng:

- tối giản cao cấp
- brutalist
- cyberpunk
- glassmorphism tinh tế
- editorial magazine
- luxury fintech
- retro futuristic
- organic/natural
- playful
- industrial
- monochrome
- soft pastel
- dark cinematic
- neo-modern
- tactile UI
- futuristic operating system
- Nhật tối giản
- Scandinavian minimalism
- experimental asymmetry

Quan trọng:
PHẢI commit mạnh vào aesthetic đã chọn.

## 3. Tạo điểm ghi nhớ

Mỗi thiết kế cần có một thứ khiến người dùng nhớ:

Ví dụ:
- typography cực mạnh
- motion độc đáo
- layout phá grid
- hiệu ứng ánh sáng
- transitions cinematic
- cards chồng lớp
- floating interactions
- animated gradients
- custom navigation
- chiều sâu không gian

------------------------------------------------------------------

# NGUYÊN TẮC THIẾT KẾ FLUTTER

## Typography

KHÔNG dùng typography generic.

Tránh:
- font mặc định Flutter
- typography vô hồn

Ưu tiên:
- Google Fonts có cá tính
- pairing display font + body font
- hierarchy mạnh
- spacing typography tinh tế

Typography phải tạo cảm xúc.

## Màu sắc

Commit vào một palette mạnh.

KHÔNG dùng:
- gradient tím generic
- màu AI phổ biến

Ưu tiên:
- palette có cá tính
- contrast rõ
- accent color có chủ đích
- màu tạo mood

Sử dụng:
- ThemeData
- ColorScheme
- constants cho màu

## Layout & Composition

Tránh layout quá predictable.

Ưu tiên:
- bất đối xứng
- overlap
- chiều sâu
- khoảng trắng có chủ đích
- layered UI
- phá grid hợp lý

Không phải màn hình nào cũng:
Column -> Card -> Button.

## Motion & Animation

Animation là bắt buộc nếu phù hợp aesthetic.

Ưu tiên:
- animation có cảm giác cinematic
- stagger animation
- smooth transitions
- implicit animations
- page transitions độc đáo
- hover/touch feedback tinh tế

Ưu tiên sử dụng:
- AnimatedContainer
- TweenAnimationBuilder
- Hero
- AnimationController
- flutter_animate
- custom transitions

Animation phải có mục đích, không spam.

## Visual Depth

Tạo chiều sâu thị giác:

- blur
- transparency
- layered surfaces
- gradients
- shadows có chủ đích
- grain/noise texture
- glowing effects
- mesh gradients

Không dùng nền phẳng nhàm chán trừ khi aesthetic yêu cầu.

------------------------------------------------------------------

# QUY TẮC CODE FLUTTER

Code phải đạt chuẩn production.

## Kiến trúc

Ưu tiên:
- reusable widgets
- tách component rõ ràng
- clean structure
- tránh nesting quá sâu

## Performance

Ưu tiên:
- const constructors
- tối ưu rebuild
- ListView.builder
- lazy loading
- animation hiệu quả

## Responsive

UI phải responsive cho:
- mobile
- tablet
- landscape

Sử dụng:
- LayoutBuilder
- MediaQuery
- Flexible
- Expanded

## Material 3

Ưu tiên Material 3 nhưng có thể custom mạnh để tạo bản sắc riêng.

Không tạo UI giống template mặc định Material.

## State Management

Nếu cần state management:
ưu tiên:
- Riverpod
- Bloc
- Cubit

Tránh state management lộn xộn.

------------------------------------------------------------------

# NHỮNG THỨ CẤM

KHÔNG tạo UI generic AI.

Tránh:

- layout template lặp lại
- card bo góc vô hồn
- màu tím gradient cliché
- spacing ngẫu nhiên
- quá nhiều Container lồng nhau
- typography yếu
- UI giống dribbble fake
- button mặc định nhàm chán
- mọi màn hình đều centered
- animation vô nghĩa

KHÔNG tạo cảm giác:
"đây là UI AI generate trong 5 giây"

------------------------------------------------------------------

# MỤC TIÊU CUỐI

Mỗi UI Flutter phải có cảm giác:

- được thiết kế có chủ đích
- có bản sắc riêng
- production-grade
- đáng nhớ
- cao cấp
- có chiều sâu
- có cảm xúc

Hãy suy nghĩ như:
- senior product designer
- senior mobile engineer
- motion designer
- art director

Không chỉ code giao diện.

Hãy tạo trải nghiệm.