import 'dart:convert';

import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:novel_flutter_bit/tools/logger_tools.dart';

/// 解析规则
/// 工具
/// 时间 2024-9-29
/// 7-bit
class ParseSourceRule {
  /// 解析所有匹配项
  /// 解析所有匹配项
  /// 解析所有匹配项
  static List<String?> parseAllMatches({
    required String rule,
    required String htmlData,
    String? rootSelector, // 根节点选择器
  }) {
    if (rule.isEmpty) {
      return [];
    }

    // 解析 HTML 数据
    Document document = parse(htmlData);

    // 选择根节点
    List<Element> rootNodes = [];
    if (rootSelector != null && rootSelector.isNotEmpty) {
      // 处理根选择器可能的多级结构
      List<String> rootParts = rootSelector.split(RegExp(r'[@>]'));
      String initialPart = rootParts[0].trim();

      // 获取初始部分的元素
      if (initialPart.startsWith('class.')) {
        String className = initialPart.split('.')[1];
        rootNodes = document.getElementsByClassName(className).toList();
      } else if (initialPart.startsWith('.')) {
        String className = initialPart.substring(1);
        rootNodes = document.getElementsByClassName(className).toList();
      } else if (initialPart.startsWith('#')) {
        String idSelector = initialPart.substring(1);
        rootNodes = document.querySelectorAll('#$idSelector').toList();
      } else if (initialPart.startsWith('id.')) {
        String idSelector = initialPart.split('.')[1];
        var element = document.querySelector('#$idSelector');
        if (element != null) {
          rootNodes.add(element);
        }
      } else if (initialPart.contains(' ')) {
        String idSelector = initialPart.replaceAll(' ', ">");
        var element = document.querySelector(idSelector);
        if (element != null) {
          rootNodes.add(element);
        }
      } else {
        rootNodes = document.getElementsByTagName(initialPart).toList();
      }

      // 逐步处理后续的选择器部分（`@` 或 `>` 分隔）
      for (int i = 1; i < rootParts.length; i++) {
        String part = rootParts[i].trim();
        List<Element> newRootNodes = [];

        if (part.startsWith('tag.')) {
          String tagName = part.split('.')[1];
          for (var element in rootNodes) {
            newRootNodes.addAll(element.getElementsByTagName(tagName));
          }
        } else if (part.startsWith('class.')) {
          String className = part.split('.')[1];
          for (var element in rootNodes) {
            newRootNodes.addAll(element.getElementsByClassName(className));
          }
        } else if (part.startsWith('a.')) {
          // 支持 a.0 形式，选择第 n 个 a 标签
          int index = int.tryParse(part.split('.')[1]) ?? 0;
          for (var element in rootNodes) {
            var aElements = element.getElementsByTagName('a');
            if (aElements.length > index) {
              newRootNodes.add(aElements[index]);
            }
          }
        } else if (part == 'text') {
          // 如果是 text，直接返回元素的文本内容
          return rootNodes.map((e) => e.text.trim()).toList();
        } else {
          if (rootSelector.contains('>')) {
            final split = rootSelector.split('@');
            for (var i = 0; i < split.length; i++) {
              final list = rootNodes[i].querySelectorAll(split[i]);
              if (list.isNotEmpty) {
                newRootNodes.addAll(list);
              }
              LoggerTools.looger.d("$i ==  我已经找到元素了长度为 ${newRootNodes.length}");
            }
          } else {
            // 如果是 text，直接返回元素的文本内容
            for (var i = 0; i < rootNodes.length; i++) {
              final list = rootNodes[i].getElementsByTagName(part);
              newRootNodes.addAll(list);
              LoggerTools.looger.d("$i ==  我已经找到元素了长度为 ${newRootNodes.length}");
            }
          }
        }
        // 更新 rootNodes 为当前级别的元素
        rootNodes = newRootNodes;
      }
    } else {
      rootNodes = [document.documentElement!]; // 默认根节点为文档根
    }
    // 解析规则字符串
    rule = processInput(rule);
    List<String> parts = rule.split('@');
    String rootPart = parts[0];
    for (var i = 0; i < parts.length; i++) {
      if (parts[i] != "") {
        rootPart = parts[i];
        break;
      }
    }
    List<Element> elements = [];

    // 处理根部分的标签选择器
    for (var rootNode in rootNodes) {
      List<Element> tempElements = [];
      if (rootPart.startsWith('class.')) {
        String className = rootPart.split('.')[1];
        tempElements.addAll(rootNode.getElementsByClassName(className));
      } else if (rootPart.startsWith(".")) {
        final data = rootPart.substring(1).split(".");
        final id = data.first;
        tempElements.addAll(rootNode.getElementsByClassName(id));
      } else if (rootPart.startsWith('#')) {
        String idSelector = rootPart.substring(1);
        var element = rootNode.querySelector('#$idSelector');
        if (element != null) {
          tempElements.add(element);
        }
      } else if (rootPart.startsWith('id.')) {
        String idSelector = rootPart.split('.')[1];
        var element = rootNode.querySelector('#$idSelector');
        if (element != null) {
          tempElements.add(element);
        }
      } else if (rule == 'text') {
        tempElements = rootNodes;
        elements.addAll(tempElements); // 合并所有匹配的元素
        break;
      } else {
        if (rootPart.contains("href")) {
          final dtat = rootNode.getElementsByTagName('a');
          dtat.map((element) {
            final href = element.attributes['href'] ?? '';
            if (href.isNotEmpty) {
              tempElements.add(element);
            }
          }).toList();
          if (dtat.isEmpty) {
            final href = rootNode.attributes['href'] ?? '';
            if (href.isNotEmpty) {
              tempElements.add(rootNode);
            }
          }
        } else if (rootPart.contains('.')) {
          final data = rootPart.split(".");
          if (data.isNotEmpty) {
            final key = data[0];
            final index = int.tryParse((data[1])) ?? 0;
            final dian = rootNode.getElementsByTagName(key);
            final element = dian.length > index ? dian[index] : null;
            if (element != null) {
              tempElements.add(element);
            }
          } else {
            tempElements.addAll(rootNode.getElementsByTagName(rootPart));
          }
        } else {
          final data = rootNode.getElementsByTagName(rootPart);
          if (data.isNotEmpty) {
            tempElements.addAll(data);
          } else {
            if (rootSelector != null && rootSelector.contains(".")) {
              final list = rootSelector.split(".");
              final data = rootNode.querySelectorAll(list.last);
              tempElements.addAll(data);
              if (parts.length == 1) {
                parts.add(parts.first);
              }
            }
          }
        }
      }
      elements.addAll(tempElements); // 合并所有匹配的元素
    }

    if (elements.isEmpty) {
      LoggerTools.looger.i('Root element not found for $rootPart');
      return []; // 找不到元素时返回空数组
    }
    bool isfor = false;
    // 逐步解析标签和属性
    // 逐步解析标签和属性
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];
      List<Element> newElements = [];
      isfor = true;

      if (part.contains('>')) {
        // 处理子元素选择器
        List<String> directParts = part.split('>');
        String parentSelector = directParts[0].trim();
        String childTag = directParts[1].trim();

        for (var element in elements) {
          var parentElements = element.getElementsByTagName(parentSelector);
          for (var parent in parentElements) {
            newElements.addAll(parent.getElementsByTagName(childTag));
          }
        }
        if (newElements.isNotEmpty) {
          elements = newElements;
        }
      } else if (part.startsWith('tag.')) {
        // 处理标签选择器
        final split = part.split('.');
        String tagName = split[1];
        if (split.length > 2) {
          final index = int.tryParse(split[2]) ?? -1;
          if (index != -1) {
            for (var element in elements) {
              newElements.add(element.getElementsByTagName(tagName)[index]);
            }
          }
        } else {
          for (var element in elements) {
            newElements.addAll(element.getElementsByTagName(tagName));
          }
        }
        if (newElements.isNotEmpty) {
          elements = newElements;
        }
      } else if (part.contains('href') || part.contains('src')) {
        // 支持 a.0@href 或 @href 格式
        final split = part.split(".");
        final data = elements.map((e) {
          if (split.length == 2) {
            int index = int.parse(split[1]);
            var aElements = e.getElementsByTagName('a');
            if (aElements.length > index) {
              return aElements[index].attributes[part] ?? '';
            }
          } else {
            var aElements = e.getElementsByTagName('a');
            if (aElements.isEmpty) {
              return e.attributes[part] ?? '';
            }
            return aElements[0].attributes[part] ?? '';
          }
        }).toList();
        return data.where((url) => url != null && url.isNotEmpty).toList();
      } else if (part.startsWith('a')) {
        // 支持 a.0@href 或 @href 格式
        final data = elements.map((e) {
          // 处理 a.0@href 格式
          if (part.startsWith('a.')) {
            var parts = part.split('.');
            if (parts.length == 2) {
              int index = int.parse(parts[1]);
              var aElements = e.getElementsByTagName('a');
              if (aElements.length > index) {
                return aElements[index].attributes['href'];
              }
            }
          } else {
            String key = 'href';
            if (parts.length >= i + 1) {
              key = parts[i + 1];
            }
            var aElements = e.getElementsByTagName('a');
            if (aElements.isEmpty) {
              return e.attributes[key];
            }
            return aElements[0].attributes[key];
          }
        }).toList();
        final list =
            data.where((url) => url != null && url.isNotEmpty).toList();
        if (list.isNotEmpty) {
          return list;
        }
      } else if (part.startsWith('text') || part.endsWith('text')) {
        return elements.map((e) => e.text.trim()).toList();
      } else if (part.contains('||')) {
        // 处理 || 分隔的属性选择器
        var attributeParts = part.split('||');
        final data = elements.map((e) {
          for (var attr in attributeParts) {
            var value = e.attributes[attr];
            if (value != null && value.isNotEmpty) {
              return value;
            }
          }
          return null;
        }).toList();
        return data
            .where((value) => value != null && value.isNotEmpty)
            .toList();
      } else if (part.startsWith('class.')) {
        // 处理 class 的选择
        final split = part.split('.');
        if (split.length == 2) {
          for (var element in elements) {
            newElements.addAll(element.getElementsByClassName(split[1]));
          }
        } else if (split.length == 3) {
          for (var element in elements) {
            if (element.text == "下一页") {
              newElements.add(element);
            }
          }
        }

        if (newElements.isNotEmpty) {
          elements = newElements;
        }
      }

      // 如果没有找到新元素，直接返回空数组
      if (elements.isEmpty) {
        return [];
      }
    }

    if (!isfor && rootPart.startsWith('href#')) {
      final data = elements.map((e) {
        // 处理 a.0@href 格式
        // var aElements = e.getElementsByTagName('a');
        return e.attributes['href'] ?? e.attributes['src'];
      }).toList();
      return data.where((url) => url != null && url.isNotEmpty).toList();
    }
    if (rule.contains("<js>")) {
      // 使用CSS选择器找到需要删除的元素并移除它们
      for (var element1 in elements) {
        element1.querySelectorAll('p').forEach((element) {
          if (element.text.contains('《') &&
              element.text.contains('(www.369book.cc)')) {
            element.remove();
          }
        });

        element1.querySelectorAll('div.book-read-link').forEach((element) {
          element.remove();
        });

        element1.querySelectorAll('p').forEach((element) {
          if (element.text.contains('本章未完') && element.text.contains('继续阅读')) {
            element.remove();
          }
        });
      }
    }

    return elements.map((e) {
      return e.text.trim();
    }).toList();
  }

  /// 解析所有匹配项
  static List<String?> parseAllMatches1({
    required String rule,
    required String htmlData,
  }) {
    if (rule == "") {
      return [];
    }
    // 解析 HTML 数据
    Document document = parse(htmlData);

    // 解析规则字符串
    List<String> parts = rule.split('@');
    String rootPart = parts[0];
    List<Element>? elements = [];

    // 处理根部分的标签选择器
    if (rootPart.startsWith('class.')) {
      String className = rootPart.split('.')[1];
      elements = document.getElementsByClassName(className).toList();
    } else if (rootPart.startsWith('#')) {
      String idSelector = rootPart.substring(1);
      Element? element = document.getElementById(idSelector);
      if (element != null) {
        elements = [element];
      }
    } else {
      elements = document.getElementsByTagName(rootPart).toList();
    }

    if (elements.isEmpty) {
      LoggerTools.looger.i('Root element not found for $rootPart');
      return [];
    }

    // 逐步解析标签和属性
    for (int i = 1; i < parts.length; i++) {
      String part = parts[i];
      List<Element> newElements = [];

      if (part.startsWith('tag.')) {
        String tagName = part.split('.')[1];
        for (var element in elements!) {
          newElements.addAll(element.getElementsByTagName(tagName));
        }
        elements = newElements;
      } else if (part.startsWith('text')) {
        return elements!.map((e) => e.text.trim()).toList();
      } else if (part.contains('href') || part.contains('src')) {
        // if (part.contains('src')) {
        //   part = 'src';
        // } else {
        //   part = 'href';
        // }
        final data = elements!.map((e) {
          return e.attributes[part]; // 获取 href 属性值
        }).toList();
        return data.where((url) => url != null && url.isNotEmpty).toList();
      }
    }

    return elements!.map((e) => e.text.trim()).toList();
  }

  /// 搜索页url解析
  static Map<String, dynamic> parseSearchUrl(
      {required String searchKey, required String searchUrl}) {
    // 从模板中提取 charset
    RegExp charsetPattern = RegExp(r'"charset":\s*"([^"]+)"');
    var match = charsetPattern.firstMatch(searchUrl);
    String charset =
        match != null ? match.group(1) ?? 'utf-8' : 'utf-8'; // 默认utf-8

    // 根据 charset 选择编码方式
    String encodedKey;
    if (charset.toLowerCase() == 'gbk') {
      encodedKey = _toGbkUrlEncoded(searchKey); // 使用 GBK 编码
    } else if (charset.toLowerCase() == 'utf-8') {
      encodedKey = _toUtf8UrlEncoded(searchKey); // 使用 UTF-8 编码
    } else {
      throw UnsupportedError('不支持的编码格式: $charset');
    }

    // 替换 searchUrl 中的 {{key}} 占位符
    String finalUrl = searchUrl.replaceAll('{{key}}', encodedKey);

    // 去掉 charset 部分
    //final split = finalUrl.split(',');
    List<String> parts = finalUrl.split(RegExp(r',(?={)'));
    //print(parts[1]);
    //String cleanUrl = split[0]; // 只保留 "," 前面的部分
    // final Response<String> data =
    //     await _dio.get("${_sourceEntry.bookSourceUrl}$cleanUrl");
    final data = {"url": parts[0]};
    if (parts.length > 1) {
      data["rule"] = parts[1];
    }
    return data;
  }

  // 对字符串进行 GBK URL 编码
  static String _toGbkUrlEncoded(String input) {
    List<int> gbkBytes = gbk.encode(input); // 将字符串转换为GBK字节
    return gbkBytes
        .map((byte) =>
            '%${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}')
        .join();
  }

// 对字符串进行 UTF-8 URL 编码
  static String _toUtf8UrlEncoded(String input) {
    List<int> utf8Bytes = utf8.encode(input); // 将字符串转换为UTF-8字节
    return utf8Bytes
        .map((byte) =>
            '%${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}')
        .join();
  }

  /// 解析url
  static String parseUrl({
    required String bookSourceUrl,
    required String parseSearchUrl,
  }) {
    var regex = RegExp(
        r'^((https?|ftp):\/\/)?([a-zA-Z0-9_-]+\.)+[a-zA-Z]{2,}(\/[^\s]*)?$');
    if (regex.hasMatch(bookSourceUrl) && regex.hasMatch(parseSearchUrl)) {
      return parseSearchUrl;
    }
    // 去除baseUrl末尾的斜杠（如果有）
    if (bookSourceUrl.endsWith('/')) {
      bookSourceUrl = bookSourceUrl.substring(0, bookSourceUrl.length - 1);
    }
    // 如果relativeUrl以斜杠开头，则去除
    if (parseSearchUrl.startsWith('/')) {
      parseSearchUrl = parseSearchUrl.substring(1);
    }
    return '$bookSourceUrl/$parseSearchUrl';
  }

  static String? parseCharset({
    required String htmlData,
  }) {
    // 解析 HTML 数据
    Document document = parse(htmlData);

    // 查找所有 <meta> 标签
    List<Element> metaTags = document.getElementsByTagName('meta').toList();

    // 遍历 <meta> 标签查找 charset 属性
    for (Element meta in metaTags) {
      String? charset = meta.attributes['charset'];
      String content = meta.attributes['content'] ??
          ""; //<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

      if (charset != null) {
        return charset; // 如果找到 charset 属性则返回
      }
      List<String> parts = content.split(';');
      for (String part in parts) {
        part = part.trim();
        if (part.startsWith('charset=')) {
          return part.split('=').last.trim();
        }
      }
    }

    return null; // 如果未找到 charset 则返回 null
  }

  /// 解析html数据 解码 不同编码
  static String parseHtmlDecode(dynamic htmlData) {
    String resultData = gbk.decode(htmlData);
    final charset = ParseSourceRule.parseCharset(htmlData: resultData) ?? "gbk";
    if (charset.toLowerCase() == "utf-8" || charset.toLowerCase() == "utf8") {
      resultData = utf8.decode(htmlData);
    }
    return resultData;
  }

  static String processInput(String input) {
    // 移除外层的 {{ 和 }}，并将内容提取出来
    String trimmedInput = input.replaceAll(RegExp(r'^\{\{|\}\}$'), '');

    // 用 || 连接各部分，处理内容
    return trimmedInput
        .split(RegExp(r'\s*\{\{\s*|\s*\}\s*')) // 以 {{ 或 }} 分割
        .where((part) => part.isNotEmpty) // 移除空部分
        .map((part) {
      // 替换连续的 @ 为一个 @，并去掉前后的空格
      return part.replaceAll(RegExp(r'@+'), '@').trim();
    }).join(' || ');
  }
}
