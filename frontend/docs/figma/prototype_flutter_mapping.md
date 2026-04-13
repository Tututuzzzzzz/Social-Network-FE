# Figma Prototype -> Flutter Mapping

- Figma file: Mạng xã hội Mochi
- Page: Prototype
- Top-level screens mapped: 91
- Deep real-screen candidates (from recursive frames): 74

## Proposed Flutter Modules

- auth: login/register/onboarding/authorization flows
- home: feed/search/notifications/post settings/general app surfaces
- reels: reels/story/camera flows
- chat: direct messages/group/chat profile/chat settings
- profile: profile/edit/avatar/privacy/block/restriction flows

## Module Distribution (Top-level 91)

| Module | Count |
|---|---:|
| auth | 7 |
| home | 30 |
| reels | 7 |
| chat | 23 |
| profile | 24 |

## Full Top-level Screen Mapping

| # | Figma ID | Figma Name | Module | Route Path | Page Class | Page File |
|---:|---|---|---|---|---|---|
| 1 | 1:1919 | Mochi Main | home | /home/mochi-main-1-1919 | MochiMainPage | lib/src/features/home/presentation/pages/mochi_main_page.dart |
| 2 | 1:2075 | Mochi Authorization | auth | /auth/mochi-authorization-1-2075 | MochiAuthorizationPage | lib/src/features/auth/presentation/pages/mochi_authorization_page.dart |
| 3 | 54:172 | Mochi Authorization | auth | /auth/mochi-authorization-54-172 | MochiAuthorizationPage | lib/src/features/auth/presentation/pages/mochi_authorization_page.dart |
| 4 | 1:2119 | Mochi Authorization | auth | /auth/mochi-authorization-1-2119 | MochiAuthorizationPage | lib/src/features/auth/presentation/pages/mochi_authorization_page.dart |
| 5 | 54:534 | Mochi Authorization | auth | /auth/mochi-authorization-54-534 | MochiAuthorizationPage | lib/src/features/auth/presentation/pages/mochi_authorization_page.dart |
| 6 | 54:81 | Mochi Authorization 2 | auth | /auth/mochi-authorization-2-54-81 | MochiAuthorization2Page | lib/src/features/auth/presentation/pages/mochi_authorization_2_page.dart |
| 7 | 54:705 | Mochi Authorization | auth | /auth/mochi-authorization-54-705 | MochiAuthorizationPage | lib/src/features/auth/presentation/pages/mochi_authorization_page.dart |
| 8 | 54:649 | Mochi Authorization | auth | /auth/mochi-authorization-54-649 | MochiAuthorizationPage | lib/src/features/auth/presentation/pages/mochi_authorization_page.dart |
| 9 | 1:2179 | Mochi Search | home | /home/mochi-search-1-2179 | MochiSearchPage | lib/src/features/home/presentation/pages/mochi_search_page.dart |
| 10 | 197:1138 | Mochi Search | home | /home/mochi-search-197-1138 | MochiSearchPage | lib/src/features/home/presentation/pages/mochi_search_page.dart |
| 11 | 197:1693 | Mochi Reels | reels | /reels/mochi-reels-197-1693 | MochiReelsPage | lib/src/features/reels/presentation/pages/mochi_reels_page.dart |
| 12 | 233:75 | Mochi Reels | reels | /reels/mochi-reels-233-75 | MochiReelsPage | lib/src/features/reels/presentation/pages/mochi_reels_page.dart |
| 13 | 249:89 | Mochi Reels chat | reels | /reels/mochi-reels-chat-249-89 | MochiReelsChatPage | lib/src/features/reels/presentation/pages/mochi_reels_chat_page.dart |
| 14 | 459:656 | Mochi Reels search | reels | /reels/mochi-reels-search-459-656 | MochiReelsSearchPage | lib/src/features/reels/presentation/pages/mochi_reels_search_page.dart |
| 15 | 459:1195 | Mochi Reels chat search | reels | /reels/mochi-reels-chat-search-459-1195 | MochiReelsChatSearchPage | lib/src/features/reels/presentation/pages/mochi_reels_chat_search_page.dart |
| 16 | 1:2500 | Mochi Picture Shot | reels | /reels/mochi-picture-shot-1-2500 | MochiPictureShotPage | lib/src/features/reels/presentation/pages/mochi_picture_shot_page.dart |
| 17 | 1:2560 | Mochi Story | reels | /reels/mochi-story-1-2560 | MochiStoryPage | lib/src/features/reels/presentation/pages/mochi_story_page.dart |
| 18 | 488:419 | Mochi Profile bạn bè | profile | /profile/mochi-profile-ban-be-488-419 | MochiProfileBanBePage | lib/src/features/profile/presentation/pages/mochi_profile_ban_be_page.dart |
| 19 | 488:660 | Mochi Profile bạn bè hạn chế | profile | /profile/mochi-profile-ban-be-han-che-488-660 | MochiProfileBanBeHanChePage | lib/src/features/profile/presentation/pages/mochi_profile_ban_be_han_che_page.dart |
| 20 | 488:1545 | Mochi Profile bạn bè hạn chế 1 | profile | /profile/mochi-profile-ban-be-han-che-1-488-1545 | MochiProfileBanBeHanChe1Page | lib/src/features/profile/presentation/pages/mochi_profile_ban_be_han_che_1_page.dart |
| 21 | 488:962 | Mochi Profile bạn bè chặn | profile | /profile/mochi-profile-ban-be-chan-488-962 | MochiProfileBanBeChanPage | lib/src/features/profile/presentation/pages/mochi_profile_ban_be_chan_page.dart |
| 22 | 488:1180 | Mochi Profile bạn bè bỏ chặn | profile | /profile/mochi-profile-ban-be-bo-chan-488-1180 | MochiProfileBanBeBoChanPage | lib/src/features/profile/presentation/pages/mochi_profile_ban_be_bo_chan_page.dart |
| 23 | 389:671 | Mochi Profile trống | profile | /profile/mochi-profile-trong-389-671 | MochiProfileTrongPage | lib/src/features/profile/presentation/pages/mochi_profile_trong_page.dart |
| 24 | 1:3504 | Mochi Add Image | home | /home/mochi-add-image-1-3504 | MochiAddImagePage | lib/src/features/home/presentation/pages/mochi_add_image_page.dart |
| 25 | 642:314 | Mochi Add Image bài viết | home | /home/mochi-add-image-bai-viet-642-314 | MochiAddImageBaiVietPage | lib/src/features/home/presentation/pages/mochi_add_image_bai_viet_page.dart |
| 26 | 389:406 | Mochi Add ảnh đại diện | profile | /profile/mochi-add-anh-dai-dien-389-406 | MochiAddAnhDaiDienPage | lib/src/features/profile/presentation/pages/mochi_add_anh_dai_dien_page.dart |
| 27 | 1:3773 | Mochi Profile Edit on | profile | /profile/mochi-profile-edit-on-1-3773 | MochiProfileEditOnPage | lib/src/features/profile/presentation/pages/mochi_profile_edit_on_page.dart |
| 28 | 389:565 | Mochi Profile Edit trống | profile | /profile/mochi-profile-edit-trong-389-565 | MochiProfileEditTrongPage | lib/src/features/profile/presentation/pages/mochi_profile_edit_trong_page.dart |
| 29 | 389:239 | Mochi Profile Edit | profile | /profile/mochi-profile-edit-389-239 | MochiProfileEditPage | lib/src/features/profile/presentation/pages/mochi_profile_edit_page.dart |
| 30 | 626:689 | Mochi Profile Edit v2 | profile | /profile/mochi-profile-edit-v2-626-689 | MochiProfileEditV2Page | lib/src/features/profile/presentation/pages/mochi_profile_edit_v2_page.dart |
| 31 | 1:3864 | Cover | profile | /profile/cover-1-3864 | CoverPage | lib/src/features/profile/presentation/pages/cover_page.dart |
| 32 | 197:640 | Option Post | home | /home/option-post-197-640 | OptionPostPage | lib/src/features/home/presentation/pages/option_post_page.dart |
| 33 | 306:614 | LOGO | home | /home/logo-306-614 | LogoPage | lib/src/features/home/presentation/pages/logo_page.dart |
| 34 | 325:376 | Cài đặt và hoạt động | home | /home/cai-dat-va-hoat-dong-325-376 | CaiDatVaHoatDongPage | lib/src/features/home/presentation/pages/cai_dat_va_hoat_dong_page.dart |
| 35 | 330:657 | Chi tiết ảnh 3 | home | /home/chi-tiet-anh-3-330-657 | ChiTietAnh3Page | lib/src/features/home/presentation/pages/chi_tiet_anh_3_page.dart |
| 36 | 433:1848 | Chi tiết ảnh 1 | home | /home/chi-tiet-anh-1-433-1848 | ChiTietAnh1Page | lib/src/features/home/presentation/pages/chi_tiet_anh_1_page.dart |
| 37 | 459:251 | Chi tiết ảnh 4 | home | /home/chi-tiet-anh-4-459-251 | ChiTietAnh4Page | lib/src/features/home/presentation/pages/chi_tiet_anh_4_page.dart |
| 38 | 459:340 | Chi tiết ảnh 5 | home | /home/chi-tiet-anh-5-459-340 | ChiTietAnh5Page | lib/src/features/home/presentation/pages/chi_tiet_anh_5_page.dart |
| 39 | 459:386 | Chi tiết ảnh 6 | home | /home/chi-tiet-anh-6-459-386 | ChiTietAnh6Page | lib/src/features/home/presentation/pages/chi_tiet_anh_6_page.dart |
| 40 | 433:1820 | Chi tiết ảnh 2 | home | /home/chi-tiet-anh-2-433-1820 | ChiTietAnh2Page | lib/src/features/home/presentation/pages/chi_tiet_anh_2_page.dart |
| 41 | 459:430 | Chi tiết ảnh 7 | home | /home/chi-tiet-anh-7-459-430 | ChiTietAnh7Page | lib/src/features/home/presentation/pages/chi_tiet_anh_7_page.dart |
| 42 | 459:475 | Chi tiết ảnh 8 | home | /home/chi-tiet-anh-8-459-475 | ChiTietAnh8Page | lib/src/features/home/presentation/pages/chi_tiet_anh_8_page.dart |
| 43 | 459:523 | Chi tiết ảnh 9 | home | /home/chi-tiet-anh-9-459-523 | ChiTietAnh9Page | lib/src/features/home/presentation/pages/chi_tiet_anh_9_page.dart |
| 44 | 407:1242 | Thông báo | home | /home/thong-bao-407-1242 | ThongBaoPage | lib/src/features/home/presentation/pages/thong_bao_page.dart |
| 45 | 332:666 | Tùy chọn | home | /home/tuy-chon-332-666 | TuyChonPage | lib/src/features/home/presentation/pages/tuy_chon_page.dart |
| 46 | 519:1242 | Tùy chọn bài đăng | home | /home/tuy-chon-bai-dang-519-1242 | TuyChonBaiDangPage | lib/src/features/home/presentation/pages/tuy_chon_bai_dang_page.dart |
| 47 | 642:292 | bàn phím | home | /home/ban-phim-642-292 | BanPhimPage | lib/src/features/home/presentation/pages/ban_phim_page.dart |
| 48 | 488:899 | Tùy chọn 1 | home | /home/tuy-chon-1-488-899 | TuyChon1Page | lib/src/features/home/presentation/pages/tuy_chon_1_page.dart |
| 49 | 488:1534 | Tùy chọn 2 | home | /home/tuy-chon-2-488-1534 | TuyChon2Page | lib/src/features/home/presentation/pages/tuy_chon_2_page.dart |
| 50 | 407:1792 | Tùy chọn ảnh 1 | home | /home/tuy-chon-anh-1-407-1792 | TuyChonAnh1Page | lib/src/features/home/presentation/pages/tuy_chon_anh_1_page.dart |
| 51 | 447:214 | Tùy chọn ảnh 3 | home | /home/tuy-chon-anh-3-447-214 | TuyChonAnh3Page | lib/src/features/home/presentation/pages/tuy_chon_anh_3_page.dart |
| 52 | 447:209 | Tùy chọn ảnh 2 | home | /home/tuy-chon-anh-2-447-209 | TuyChonAnh2Page | lib/src/features/home/presentation/pages/tuy_chon_anh_2_page.dart |
| 53 | 389:157 | Chuyển sang riêng tư | profile | /profile/chuyen-sang-rieng-tu-389-157 | ChuyenSangRiengTuPage | lib/src/features/profile/presentation/pages/chuyen_sang_rieng_tu_page.dart |
| 54 | 389:351 | Chọn ảnh đại diện | profile | /profile/chon-anh-dai-dien-389-351 | ChonAnhDaiDienPage | lib/src/features/profile/presentation/pages/chon_anh_dai_dien_page.dart |
| 55 | 389:197 | Chuyển sang công khai | profile | /profile/chuyen-sang-cong-khai-389-197 | ChuyenSangCongKhaiPage | lib/src/features/profile/presentation/pages/chuyen_sang_cong_khai_page.dart |
| 56 | 506:679 | bài và tin | home | /home/bai-va-tin-506-679 | BaiVaTinPage | lib/src/features/home/presentation/pages/bai_va_tin_page.dart |
| 57 | 519:1180 | Mochi viết bài | home | /home/mochi-viet-bai-519-1180 | MochiVietBaiPage | lib/src/features/home/presentation/pages/mochi_viet_bai_page.dart |
| 58 | 579:233 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-233 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 59 | 579:483 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-483 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 60 | 579:625 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-625 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 61 | 579:750 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-750 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 62 | 579:872 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-872 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 63 | 579:993 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-993 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 64 | 579:1117 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-1117 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 65 | 579:1244 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-1244 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 66 | 579:1376 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-1376 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 67 | 579:1513 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-1513 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 68 | 579:1655 | Mochi Direct Messages | chat | /chat/mochi-direct-messages-579-1655 | MochiDirectMessagesPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_page.dart |
| 69 | 579:1796 | Mochi Direct Messages nhóm | chat | /chat/mochi-direct-messages-nhom-579-1796 | MochiDirectMessagesNhomPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_nhom_page.dart |
| 70 | 579:1879 | Mochi Direct Messages nhóm ảnh nhóm | chat | /chat/mochi-direct-messages-nhom-anh-nhom-579-1879 | MochiDirectMessagesNhomAnhNhomPage | lib/src/features/chat/presentation/pages/mochi_direct_messages_nhom_anh_nhom_page.dart |
| 71 | 579:1944 | Chọn ảnh nhóm | chat | /chat/chon-anh-nhom-579-1944 | ChonAnhNhomPage | lib/src/features/chat/presentation/pages/chon_anh_nhom_page.dart |
| 72 | 579:2014 | Mochi Profile chat | chat | /chat/mochi-profile-chat-579-2014 | MochiProfileChatPage | lib/src/features/chat/presentation/pages/mochi_profile_chat_page.dart |
| 73 | 579:2120 | Anh chi tiet | home | /home/anh-chi-tiet-579-2120 | AnhChiTietPage | lib/src/features/home/presentation/pages/anh_chi_tiet_page.dart |
| 74 | 579:2189 | Mochi Mickname | chat | /chat/mochi-mickname-579-2189 | MochiMicknamePage | lib/src/features/chat/presentation/pages/mochi_mickname_page.dart |
| 75 | 579:2231 | Mochi Mickname | chat | /chat/mochi-mickname-579-2231 | MochiMicknamePage | lib/src/features/chat/presentation/pages/mochi_mickname_page.dart |
| 76 | 579:2364 | Mochi nickname component | chat | /chat/mochi-nickname-component-579-2364 | MochiNicknameComponentPage | lib/src/features/chat/presentation/pages/mochi_nickname_component_page.dart |
| 77 | 579:2381 | Mochi Tạo nhóm | chat | /chat/mochi-tao-nhom-579-2381 | MochiTaoNhomPage | lib/src/features/chat/presentation/pages/mochi_tao_nhom_page.dart |
| 78 | 579:2505 | Mochi Tạo nhóm | chat | /chat/mochi-tao-nhom-579-2505 | MochiTaoNhomPage | lib/src/features/chat/presentation/pages/mochi_tao_nhom_page.dart |
| 79 | 579:2565 | Mochi my nick name | chat | /chat/mochi-my-nick-name-579-2565 | MochiMyNickNamePage | lib/src/features/chat/presentation/pages/mochi_my_nick_name_page.dart |
| 80 | 579:2582 | Mochi tên nhóm | chat | /chat/mochi-ten-nhom-579-2582 | MochiTenNhomPage | lib/src/features/chat/presentation/pages/mochi_ten_nhom_page.dart |
| 81 | 579:2607 | Lựa chọn | home | /home/lua-chon-579-2607 | LuaChonPage | lib/src/features/home/presentation/pages/lua_chon_page.dart |
| 82 | 579:2626 | Trang đã hạn chế | profile | /profile/trang-da-han-che-579-2626 | TrangDaHanChePage | lib/src/features/profile/presentation/pages/trang_da_han_che_page.dart |
| 83 | 579:2684 | Trang đã chặn | profile | /profile/trang-da-chan-579-2684 | TrangDaChanPage | lib/src/features/profile/presentation/pages/trang_da_chan_page.dart |
| 84 | 579:2730 | Confirm bỏ chặn ? | profile | /profile/confirm-bo-chan-579-2730 | ConfirmBoChanPage | lib/src/features/profile/presentation/pages/confirm_bo_chan_page.dart |
| 85 | 579:2737 | Confirm bỏ chặn ? | profile | /profile/confirm-bo-chan-579-2737 | ConfirmBoChanPage | lib/src/features/profile/presentation/pages/confirm_bo_chan_page.dart |
| 86 | 579:2744 | Mochi Profile chat | chat | /chat/mochi-profile-chat-579-2744 | MochiProfileChatPage | lib/src/features/chat/presentation/pages/mochi_profile_chat_page.dart |
| 87 | 579:2875 | Chặn | profile | /profile/chan-579-2875 | ChanPage | lib/src/features/profile/presentation/pages/chan_page.dart |
| 88 | 579:2959 | Mochi Profile | profile | /profile/mochi-profile-579-2959 | MochiProfilePage | lib/src/features/profile/presentation/pages/mochi_profile_page.dart |
| 89 | 579:3170 | Mochi Profile 1 | profile | /profile/mochi-profile-1-579-3170 | MochiProfile1Page | lib/src/features/profile/presentation/pages/mochi_profile_1_page.dart |
| 90 | 626:479 | Mochi Profile 2 | profile | /profile/mochi-profile-2-626-479 | MochiProfile2Page | lib/src/features/profile/presentation/pages/mochi_profile_2_page.dart |
| 91 | 579:3377 | Mochi Profile chia sẻ | profile | /profile/mochi-profile-chia-se-579-3377 | MochiProfileChiaSePage | lib/src/features/profile/presentation/pages/mochi_profile_chia_se_page.dart |

## Suggested Route Files (Next Coding Step)

- lib/src/routes/app_route_path.dart: keep global route enum names and paths.
- lib/src/routes/app_route_conf.dart: register module route trees via GoRouter.
- lib/src/features/auth/presentation/pages/*.dart
- lib/src/features/home/presentation/pages/*.dart
- lib/src/features/reels/presentation/pages/*.dart
- lib/src/features/chat/presentation/pages/*.dart
- lib/src/features/profile/presentation/pages/*.dart