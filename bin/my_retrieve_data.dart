/// - dart:convert 用于JSON编码和解码。
/// - package:http/http.dart 作为http请求的封装库。
import 'dart:convert';
import 'package:http/http.dart' as http;

/// 主函数，异步执行打印指定包信息的任务。
void main() async {
  /// 分别获取并打印'http'与'path'包的信息
  await printPackageInformation('http');
  print('');
  await printPackageInformation('path');
}

/// 异步函数，用于获取并打印指定包的详细信息。
///
/// @param packageName 要查询的Dart包的名称。
Future<void> printPackageInformation(String packageName) async {
  try {
    /// 获取包信息
    final PackageInfo packageInfo = await getPackage(packageName);

    /// 打印包的详细信息
    printPackageDetails(packageInfo);
  } on PackageRetrievalException catch (e) {
    /// 捕获并打印包检索异常
    print(e);
  }
}

/// 异步函数，根据包名从dart.dev获取包信息。
///
/// @param packageName 包名。
/// @return 一个包含包信息的[PackageInfo]对象的Future。
/// @throws [PackageRetrievalException] 如果请求不成功。
Future<PackageInfo> getPackage(String packageName) async {
  final packageUrl = Uri.https('dart.dev', '/f/packages/$packageName.json');
  final packageResponse = await http.get(packageUrl);

  /// 检查响应状态码，非200抛出异常
  if (packageResponse.statusCode != 200) {
    throw PackageRetrievalException(
      packageName: packageName,
      statusCode: packageResponse.statusCode,
    );
  }

  /// 解析JSON响应为[PackageInfo]
  return PackageInfo.fromJson(json.decode(packageResponse.body));
}

/// 包信息的数据模型类。
class PackageInfo {
  final String name;
  final String latestVersion;
  final String description;
  final String publisher;
  final Uri? repository;

  /// 从JSON构造[PackageInfo]实例。
  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
      name: json['name'] as String,
      latestVersion: json['latestVersion'] as String,
      description: json['description'] as String,
      publisher: json['publisher'] as String,
      repository: json['repository'] != null
          ? Uri.tryParse(json['repository'] as String)
          : null,
    );
  }

  /// 包信息类的构造函数。
  PackageInfo({
    required this.name,
    required this.latestVersion,
    required this.description,
    required this.publisher,
    this.repository,
  });
}

/// 自定义异常类，表示在尝试检索包信息时发生的错误。
class PackageRetrievalException implements Exception {
  final String packageName;
  final int? statusCode;

  /// 构造函数。
  ///
  /// @param packageName 出错的包名。
  /// @param [statusCode] HTTP响应状态码，可选。
  PackageRetrievalException({required this.packageName, this.statusCode});

  @override
  String toString() {
    return 'Failed to retrieve package:${packageName} information'
        '${statusCode != null ? ' with a status code of $statusCode' : ''}!';
  }
}

/// 辅助函数，用于打印单个[PackageInfo]对象的详细信息。
///
/// @param packageInfo 要打印的包信息对象。
void printPackageDetails(PackageInfo packageInfo) {
  print('Information about the ${packageInfo.name} package:');
  print('Latest version: ${packageInfo.latestVersion}');
  print('Description: ${packageInfo.description}');
  print('Publisher: ${packageInfo.publisher}');

  if (packageInfo.repository != null) {
    print('Repository: ${packageInfo.repository}');
  }
}
