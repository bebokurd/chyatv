# CHYA TV (چیا تیڤی) 🎬

> ئەپڵیکەیشنی فەرمی **CHYA TV** بۆ سەیرکردنی فیلم، زنجیرە، ئەنیمێ و کارتۆنی دۆبلاژکراوی کوردی بە دیزاینی نێتفلیکس بۆ سیستەمی iOS و ئەندرۆید.
> Official **CHYA TV** Kurdish streaming application with Netflix UI/UX, powered by Flutter, TMDB API, and direct HLS/MP4 streaming.

---

## 📱 تایبەتمەندییە سەرەکییەکان (Features)

- **🎨 دیزاینی پێشکەوتووی نێتفلیکس (Netflix UI/UX):**
  - شێوازی تاریک (Dark Theme) بە ڕەنگی نێتفلیکس (`#141414` و `#E50914`).
  - هێرۆ بانەری سەرەکی (Hero Banner) بە وێنەی بەکدرۆپ و دوگمەی لێدانی ڕاستەوخۆ.
  - ڕیزی ئاسۆیی بەرهەمەکان (Horizontal Media Rows) لەگەڵ پۆستەری HD.
  - پۆستەری تایبەت بە تاگی "کوردی" و "HD".

- **📂 بەشە سەرەکییەکانی ئەپڵیکەیشن:**
  - **سەرەکی (Home):** تازەترین بەرهەمەکان، فیلم و زنجیرە هەڵبژێردراوەکان، و پێشنیازکراوەکان.
  - **فیلم (Movies):** تەواوی فیلمە دۆبلاژکراوە کوردییەکان + فیلمە بەناوبانگەکانی جیهان لە TMDB.
  - **زنجیرە (Series):** زنجیرە دراماکان لەگەڵ لیستی وەرز و ئەڵقەکان (Episode Selector).
  - **منداڵان (Kids):** کارتۆن و ئەنیمەیشنی دۆبلاژکراوی کوردی بۆ منداڵان.
  - **ئەنیمێ (Anime):** ئەنیمێیە ژاپۆنی و جیهانییەکان بە کوالیتی بەرز.
  - **گەڕان (Search):** گەڕانی خێرا و ڕاستەوخۆ بە زمانی کوردی و ئینگلیزی بەناو کەتەلۆگ و TMDB.

- **🎥 ڤیدیۆ پلەیەر (Built-in Video Player):**
  - پەخشکردنی ڕاستەوخۆی ڤیدیۆی MP4 و ستریمی HLS (`.m3u8`).
  - کۆنتڕۆڵی پێشکەوتوو: دواخستن و پێشخستنی ۱۰ چرکە، گۆڕینی کات (Scrubbing)، شاشەی پڕ (Fullscreen).
  - پشتگیری کردنەوە بە وێبگەڕ یان پلەیەرە دەرەکییەکان (وەک VLC).

- **🌐 سەرچاوەی داتا و API:**
  - **کەتەلۆگی کوردی:** `https://bebokurd.github.io/lala.json` (بە ستریمی خێرای سەرهێڵ).
  - **زانیاری TMDB:** وەرگرتنی کورتەی چیرۆک (Overview)، وێنەی پشتەوە (Backdrop)، هەڵسەنگاندن (Rating)، و بەرهەمی هاوشێوە.
  - **پاشەکەوتکردنی ئۆفلاین (Offline Fallback):** ئەپڵیکەیشن بەبێ ئینتەرنێتیش پڕ لە بەرهەمی پاشەکەوتکراوە.

---

## 🏗 تەلارسازی پڕۆژەکە (Project Structure)

```text
lib/
├── main.dart                  # خاڵی دەستپێکی بەرنامە (RTL Kurdish & Theme)
├── models/
│   └── media_item.dart        # مۆدێلی داتا بۆ فیلم، زنجیرە، و ئەڵقەکان
├── services/
│   ├── lala_service.dart      # هێنانی داتای lala.json و کەشکردنی ناوخۆیی
│   └── tmdb_service.dart      # بەستنەوە بە The Movie Database API
├── theme/
│   └── netflix_theme.dart     # ڕەنگ و ستایلی نێتفلیکس
├── screens/
│   ├── root_screen.dart       # ناڤیگەیشنی خوارەوە و سەرەوە
│   ├── home_screen.dart       # شاشەی سەرەکی
│   ├── movies_screen.dart     # شاشەی فیلمەکان
│   ├── series_screen.dart     # شاشەی زنجیرەکان
│   ├── kids_screen.dart       # بەشی منداڵان
│   ├── anime_screen.dart      # بەشی ئەنیمێ
│   ├── search_screen.dart     # گەڕانی خێرا
│   ├── detail_screen.dart     # زانیاری تەواوی بەرهەم و ئەڵقەکان
│   └── player_screen.dart     # پەخشکەری ڤیدیۆ
└── widgets/
    ├── hero_banner.dart       # هێرۆی سەرەکی
    ├── media_card.dart        # کارتی پۆستەر
    ├── media_row.dart         # ڕیزبەندی ئاسۆیی
    └── netflix_top_bar.dart   # بارەگای سەرەوە بە لۆگۆی CHYA TV
```

---

## 🚀 شێوازی دامەزراندن و کارپێکردن (Getting Started)

### پێداویستییەکان:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (وەشانی 3.1.0 یان بەرزتر)
- [Dart SDK](https://dart.dev)
- Xcode (بۆ تاقیکردنەوە لەسەر iOS) یان Android Studio (بۆ ئەندرۆید)

### فەرمانەکان:

1. **داگرتنی پاکێجەکان:**
   ```bash
   flutter pub get
   ```

2. **کارپێکردن لەسەر مۆبایل یان شاشە (Run):**
   ```bash
   flutter run
   ```

3. **دروستکردنی پاکێجی ئەندرۆید (APK):**
   ```bash
   flutter build apk --release
   ```

---

## 🍏 دروستکردنی فایلی iOS IPA بەبێ ماک (GitHub Actions CI/CD)

پڕۆژەکە خاوەنی دوو ۆرکفلۆوی ئۆتۆماتیکییە لە `.github/workflows/dart.yml` و `ios_build.yml`:

1. لە کاتی هەر `git push`ێک بۆ برانچی `main` یان `master`:
   - سێرڤەری macOS Runner لەسەر گیتھەب ئەپەکە بە شێوازی Release کۆمپایل دەکات.
   - ئەپەکە دەگۆڕێت بۆ فایلی `ChyaTV-unsigned.ipa`.
2. دوای تەواوبوون، لە بەشی **Actions** دەتوانیت ڕاستەوخۆ فایلی **`ChyaTV-iOS-unsigned`** داببەزێنیت.
3. دەتوانیت لە ڕێگەی **TrollStore**، **AltStore**، یان **Sideloadly** لەسەر هەموو ئایفۆنێک دایمەزرێنیت بەبێ ئەکاونتی ئەپڵ دێڤلۆپەر.

---

## 🔑 دەستکاری کلیلی TMDB و سەرچاوەکان

- **TMDB API Key:** لە ناو `lib/services/tmdb_service.dart` داندراوە:
  ```dart
  static const String apiKey = '8639372f4a9255120794124116c6e93f';
  ```
- **کەتەلۆگی لالا (JSON Catalog):**
  لە ناو `lib/services/lala_service.dart`:
  ```dart
  static const String lalaUrl = 'https://bebokurd.github.io/lala.json';
  ```

---

## 📄 مافەکان (License)
ئەم پڕۆژەیە بە سەرچاوەی کراوە بۆ پەرەپێدانی کەناڵ و ئەپی **CHYA TV** ئامادە کراوە.
