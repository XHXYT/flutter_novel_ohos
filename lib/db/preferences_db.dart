import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:novel_flutter_bit/entry/book_source_entry.dart';
import 'package:novel_flutter_bit/n_pages/history/entry/history_entry.dart';
import 'package:novel_flutter_bit/n_pages/like/enrty/like_entry.dart';
import 'package:novel_flutter_bit/pages/collect_novel/enrty/collect_entry.dart';
import 'package:novel_flutter_bit/pages/home/entry/novel_history_entry.dart';
import 'package:novel_flutter_bit/pages/novel/enum/novel_read_font_weight_enum.dart';
import 'package:novel_flutter_bit/theme/app_theme.dart';
import 'package:novel_flutter_bit/tools/logger_tools.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences
class SharedPreferencesAsync {
  // 获取一个 SharedPreferences 实例
  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // 异步读取字符串
  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key);
  }

  // 异步读取布尔值
  Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(key);
  }

  // 异步读取整数
  Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt(key);
  }

  // 异步读取浮点数
  Future<double?> getDouble(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getDouble(key);
  }

  // 异步读取字符串列表
  Future<List<String>?> getStringList(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getStringList(key);
  }

  // 异步保存字符串
  Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(key, value);
  }

  // 异步保存布尔值
  Future<bool> setBool(String key, bool value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool(key, value);
  }

  // 异步保存整数
  Future<bool> setInt(String key, int value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(key, value);
  }

  // 异步保存浮点数
  Future<bool> setDouble(String key, double value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setDouble(key, value);
  }

  // 异步保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setStringList(key, value);
  }

  // 异步移除键值对
  Future<bool> remove(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(key);
  }

  // 异步清除所有偏好设置
  Future<bool> clear() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.clear();
  }
}

class PreferencesDB {
  PreferencesDB._();
  static final PreferencesDB instance = PreferencesDB._();
  SharedPreferencesAsync? _instance;
  SharedPreferencesAsync get sps => _instance ??= SharedPreferencesAsync();

  /*** APP相关 ***/

  /// 主题外观模式
  ///
  /// system(默认)：跟随系统 light：普通 dark：深色
  static const appThemeDarkMode = 'appThemeDarkMode';

  /// 多主题模式
  ///
  /// default(默认)
  static const appMultipleThemesMode = 'appMultipleThemesMode';

  /// 字体大小
  ///
  ///
  static const fontSize = 'fontSize';

  /// 字体粗细
  static const fontWeight = 'fontWeight';

  /// 阅读记录
  static const novelHistory = "novelHistory";

  static const senseLikeNovel = "setSenseLikeNovel";

  static const novelSource = "novelSource";

  /// 阅读记录
  static const history = "history";

  static const backgroundState = "backgroundState";

  /// 背景颜色
  static const backgroundColor = "backgroundColor";

  /// 文字颜色
  static const textColor = "textColor";
  static const selectedTextColor = "selectedTextColor";

  /// 设置-主题外观模式
  Future<void> setAppThemeDarkMode(ThemeMode themeMode) async {
    await sps.setString(appThemeDarkMode, themeMode.name);
  }

  /// 获取-主题外观模式
  Future<ThemeMode> getAppThemeDarkMode() async {
    final String themeDarkMode =
        await sps.getString(appThemeDarkMode) ?? 'system';
    return darkThemeMode(themeDarkMode);
  }

  /// 设置-多主题模式
  Future<void> setMultipleThemesMode(String value) async {
    await sps.setString(appMultipleThemesMode, value);
  }

  /// 获取-多主题模式
  Future<String> getMultipleThemesMode() async {
    return await sps.getString(appMultipleThemesMode) ?? 'default';
  }

  /// 获取-fontsize 大小 默认18
  Future<double> getNovelFontSize() async {
    return await sps.getDouble(fontSize) ?? 18;
  }

  /// 设置 -fontsize 大小
  Future<void> setNovelFontSize(double size) async {
    await sps.setDouble(fontSize, size);
  }

  /// 设置-多主题模式
  Future<void> setNovelFontWeight(NovelReadFontWeightEnum value) async {
    await sps.setString(fontWeight, value.id);
  }

  /// 获取-多主题模式
  Future<String> getNovelFontWeight() async {
    return await sps.getString(fontWeight) ?? 'w300';
  }

  @Deprecated("弃用")
  Future<List<NovelHistoryEntry>> getNovelHistoryList() async {
    List<NovelHistoryEntry> list = [];
    List<String> str = await sps.getStringList(novelHistory) ?? [];
    for (var element in str) {
      list.add(NovelHistoryEntry.fromJson(json.decode(element)));
    }
    return list;
  }

  @Deprecated("弃用")
  Future<void> setNovelHistory(NovelHistoryEntry novelHistoryEntry) async {
    List<String> str = [];
    final data = await getNovelHistoryList();
    final exists =
        data.any((novel) => novel.readUrl == novelHistoryEntry.readUrl);
    if (exists) {
      // 如果用户存在，移除该用户
      data.removeWhere((user) => user.readUrl == novelHistoryEntry.readUrl);
    }
    data.insert(0, novelHistoryEntry);
    for (var element in data) {
      str.add(json.encode(element.toJson()));
    }
    updateCollect(novelHistoryEntry);
    await sps.setStringList(novelHistory, str);
  }

  @Deprecated("弃用")

  /// 更新收藏阅读记录
  Future<void> updateCollect(NovelHistoryEntry novelHistoryEntry) async {
    if (await getSenseLikeNovel(novelHistoryEntry.readUrl ?? "")) {
      CollectNovelEntry collectNovelEntry = CollectNovelEntry(
        name: novelHistoryEntry.name,
        imageUrl: novelHistoryEntry.imageUrl,
        readUrl: novelHistoryEntry.readUrl,
        readChapter: novelHistoryEntry.readChapter,
        datumNew: novelHistoryEntry.datumNew,
      );
      setSenseLikeNovel(
          novelHistoryEntry.readUrl ?? "", true, collectNovelEntry,
          firstAdd: false);
    }
  }

  ///  获取-是否喜欢
  Future<bool> getSenseLikeNovel(String key) async {
    LoggerTools.looger.d("获取是否收藏  getSenseLikeNovel key:$key");
    return await sps.getBool("${key}_SenseLike") ?? false;
  }

  /// 设置-是否喜欢
  Future<void> setSenseLikeNovel(
      String key, bool value, CollectNovelEntry? entry,
      {bool firstAdd = true}) async {
    LoggerTools.looger.d("设置是否收藏 setSenseLikeNovel  key:$key  value:$value");
    await sps.setBool("${key}_SenseLike", value);
    if (value && entry != null) {
      List<String> str = [];
      final data = await getCollectNovelList();
      final exists = data.any((novel) => novel.readUrl == entry.readUrl);
      if (exists) {
        // 如果用户存在，移除该用户
        if (firstAdd) {
          data.removeWhere((user) => user.readUrl == entry.readUrl);
          data.insert(0, entry);
        } else {
          int index = data.indexWhere((user) => user.readUrl == entry.readUrl);
          data[index] = entry;
        }
      } else {
        data.insert(0, entry);
      }

      for (var element in data) {
        str.add(json.encode(element.toJson()));
      }
      await sps.setStringList(senseLikeNovel, str);
    }
  }

  /// 获取-收藏列表
  Future<List<CollectNovelEntry>> getCollectNovelList() async {
    List<CollectNovelEntry> list = [];
    List<String> str = await sps.getStringList(senseLikeNovel) ?? [];
    for (var element in str) {
      list.add(CollectNovelEntry.fromJson(json.decode(element)));
    }
    LoggerTools.looger.d("获取收藏列表  getCollectNovelList  list:$list");
    return list;
  }

  /// 获取-书籍源
  Future<List<BookSourceEntry>> getNovelSourceList() async {
    List<BookSourceEntry> list = [];
    List<String> data = await sps.getStringList(novelSource) ?? [];

    /// List<String> str = await sps.getStringList(senseLikeNovel) ?? [];
    for (var element in data) {
      list.add(BookSourceEntry.fromJson(json.decode(element)));
    }
    LoggerTools.looger.d("获取-书籍源  getNovelSourceList  list:$list");
    return list;
  }

  Future<void> setNovelSourceList(BookSourceEntry bookSource) async {
    List<BookSourceEntry> list = await getNovelSourceList();
    list.add(bookSource);
    LoggerTools.looger.d("设置-书籍源  setNovelSourceList  list:$list");
    List<String> str = [];
    for (var element in list) {
      str.add(json.encode(element));
    }
    await sps.setStringList(novelSource, str);
  }

  /// 设置-是否喜欢
  Future<void> setLike(String key, bool value, LikeEntry? like,
      {bool firstAdd = true}) async {
    LoggerTools.looger.d("设置是否收藏 setSenseLikeNovel  key:$key  value:$value");
    await sps.setBool("${key}_SenseLike", value);
    if (like != null) {
      List<String> str = [];
      final data = await getLikeList();
      if (value) {
        final exists = data.any(
            (novel) => novel.chapter?.chapterUrl == like.chapter?.chapterUrl);
        if (exists) {
          // 如果用户存在，移除该用户
          if (firstAdd) {
            data.removeWhere(
                (user) => user.chapter?.chapterUrl == like.chapter?.chapterUrl);
            data.insert(0, like);
          } else {
            int index = data.indexWhere(
                (user) => user.chapter?.chapterUrl == like.chapter?.chapterUrl);
            data[index] = like;
          }
        } else {
          data.insert(0, like);
        }
      } else {
        data.removeWhere(
            (user) => user.chapter?.chapterUrl == like.chapter?.chapterUrl);
      }
      for (var element in data) {
        str.add(json.encode(element));
      }
      await sps.setStringList(senseLikeNovel, str);
    }
  }

  /// 获取-收藏列表
  Future<List<LikeEntry>> getLikeList() async {
    List<LikeEntry> list = [];
    List<String> str = await sps.getStringList(senseLikeNovel) ?? [];
    for (var element in str) {
      list.add(LikeEntry.fromJson(json.decode(element)));
    }
    LoggerTools.looger.d("获取收藏列表  getCollectNovelList  list:$list");
    return list;
  }

  /// 更新我喜欢阅读记录
  Future<void> updateLikeChapter(LikeEntry? like) async {
    List<String> str = [];
    final data = await getLikeList();
    if (like != null) {
      for (var i = 0; i < data.length; i++) {
        if (data[i].searchEntry?.url == like.searchEntry?.url) {
          data[i] = like;
        }
      }
    }
    for (var element in data) {
      str.add(json.encode(element));
    }
    await sps.setStringList(senseLikeNovel, str);
  }

  /// 获取-历史记录列表
  Future<List<HistoryEntry>> getHistoryList() async {
    List<HistoryEntry> list = [];
    List<String> str = await sps.getStringList(history) ?? [];
    for (var element in str) {
      list.add(HistoryEntry.fromJson(json.decode(element)));
    }
    LoggerTools.looger.d("获取历史记录列表  getHistoryList  list:$list");
    return list;
  }

  /// 添加-历史记录
  Future<void> setHistory(HistoryEntry historyEntry) async {
    List<String> str = [];
    final historyList = await getHistoryList();
    historyList.insert(0, historyEntry);
    for (var element in historyList) {
      str.add(json.encode(element));
    }
    LoggerTools.looger.d("添加历史记录  setHistory");
    await sps.setStringList(history, str);
  }

  Future<void> setBackgroundImage(Uint8List? data) async {
    if (data == null) {
      return;
    }
    // 获取临时文件目录
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/$backgroundState.png');
    setBackgroundImageState(true);
    // 写入文件
    final fileImage = await file.writeAsBytes(data);
    LoggerTools.looger
        .d("写入文件  setBackgroundImage  fileImage:${fileImage.path}");
  }

  /// 获取背景图片
  Future<Uint8List?> getBackgroundImage() async {
    if (await getBackgroundImageState()) {
      // 获取临时文件目录
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      final file = File('$path/$backgroundState.png');
      LoggerTools.looger.d("获取背景图片  getBackgroundImage  file:${file.path}");
      return await file.readAsBytes();
    }
    return null;
  }

  /// 获取背景图片状态
  Future<bool> getBackgroundImageState() async {
    return await sps.getBool(backgroundState) ?? false;
  }

  /// 设置背景图片状态
  Future<void> setBackgroundImageState(bool state) async {
    await sps.setBool(backgroundState, state);
  }

  /// 设置背景颜色
  Future<void> setBackgroundColor(int color) async {
    await sps.setInt(backgroundColor, color);
  }

  /// 获取背景颜色
  Future<int> getBackgroundColor() async {
    return await sps.getInt(backgroundColor) ?? 0xfffafafa;
  }

  /// 获取文字颜色
  Future<int> getTextColor() async {
    return await sps.getInt(textColor) ?? 0xff000000;
  }

  /// 设置文字颜色
  Future<void> setTextColor(int color) async {
    await sps.setInt(textColor, color);
  }

  /// 获取选中文字颜色
  Future<int> getSelectedTextColor() async {
    return await sps.getInt(selectedTextColor) ?? 0xff000000;
  }

  /// 设置选中文字颜色
  Future<void> setSelectedTextColor(int color) async {
    await sps.setInt(selectedTextColor, color);
  }
}
