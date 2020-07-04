import 'dart:io';

import 'package:pubspec_lock/pubspec_lock.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

import '../configs/constants.dart' as constants;
import '../configs/default_settings.dart';
import '../enums/file_extension.dart';
import '../enums/report_dependency_type.dart';
import '../extensions/package_dependency_extensions.dart';
import '../models/dependency.dart';
import '../models/report_content.dart';
import '../models/sdk.dart';
import '../models/settings.dart';
import 'github_scraper.dart';
import 'md_generator.dart';
import 'pdf_generator.dart';
import 'pub_dev_scraper.dart';

/// A class which can generate a report on a project's dependencies
class DependencyReport {
  /// Generates a report for given settings
  static void generate(Settings settings) async {
    // determine settings
    final title = settings?.title ?? DefaultSettings.title;
    final outputDirectory = settings?.outputDirectory ?? DefaultSettings.outputDirectory;
    final outputFilename = settings?.outputFilename ?? DefaultSettings.outputFilename;
    final generatePdf = settings?.generatePdf ?? DefaultSettings.generatePdf;
    final generateMd = settings?.generateMd ?? DefaultSettings.generateMd;

    if (generatePdf == false && generateMd == false) {
      print('Error! No file types seleted to be generated. Exiting.');
      exit(0);
    }

    const _pubspecYamlPath = 'pubspec.yaml';
    const _pubspecLockPath = 'pubspec.lock';

    // determine project name and version
    String projectName, projectVersion;
    try {
      final pubspecYaml = File(_pubspecYamlPath).readAsStringSync().toPubspecYaml();
      projectName = pubspecYaml.name;
      projectVersion = pubspecYaml.version.valueOr(() => null);
    } on Exception catch (_) {}
    projectName ??= constants.unknown;
    projectVersion ??= constants.unknown;

    int totalNumberDependencies;
    List<SDK> sdks;
    List<PackageDependency> direct, dev, transitive, git, path;
    try {
      final pubspecLock = File(_pubspecLockPath).readAsStringSync().loadPubspecLockFromYaml();

      // determine total number of dependencies
      totalNumberDependencies = pubspecLock.packages.length;

      sdks = pubspecLock.sdks.map((sdk) => SDK(name: sdk.sdk, version: sdk.version)).toList();

      // determine lists
      direct = pubspecLock.packages
          .where((package) => package.type() == DependencyType.direct && !package.isGit && !package.isPath)
          .toList();
      dev = pubspecLock.packages
          .where((package) => package.type() == DependencyType.development && !package.isGit && !package.isPath)
          .toList();
      transitive = pubspecLock.packages
          .where((package) => package.type() == DependencyType.transitive && !package.isGit && !package.isPath)
          .toList();
      git = pubspecLock.packages.where((package) => package.isGit).toList();
      path = pubspecLock.packages.where((package) => package.isPath).toList();
    } on Exception catch (_) {}

    if (direct == null || dev == null || transitive == null || git == null || path == null) {
      print('Error! Unable to determine dependencies. Exiting.');
      exit(0);
    }

    final directDeps = await _fromPubDev(direct, type: ReportDependencyType.direct);
    final devDeps = await _fromPubDev(dev, type: ReportDependencyType.dev);
    final transitiveDeps = await _fromPubDev(transitive, type: ReportDependencyType.transitive);

    final gitDeps = <Dependency>[];
    for (final package in git) {
      final license = package.isHostedByCustomGit('github')
          ? await GitHubScraper.licenseForProject(package.url)
          : constants.unknown;
      gitDeps.add(Dependency(
        name: package.package(),
        version: package.version(),
        type: package.type(),
        reportType: ReportDependencyType.git,
        license: license,
        url: package.gitUrl,
        ref: package.gitRef,
      ));
    }

    final pathDeps = <Dependency>[];
    for (final package in path) {
      pathDeps.add(Dependency(
        name: package.package(),
        version: package.version(),
        type: package.type(),
        reportType: ReportDependencyType.path,
      ));
    }

    final userDefinedGroupsDeps = <String, List<Dependency>>{};
    if (settings.userDefinedGroups != null && settings.userDefinedGroups.isNotEmpty) {
      for (final userDefinedGroup in settings.userDefinedGroups) {
        final deps = <Dependency>[];
        deps.addAll(directDeps.where((dep) => userDefinedGroup.nameRegexp.hasMatch(dep.name)));
        deps.addAll(devDeps.where((dep) => userDefinedGroup.nameRegexp.hasMatch(dep.name)));
        deps.addAll(transitiveDeps.where((dep) => userDefinedGroup.nameRegexp.hasMatch(dep.name)));
        deps.addAll(gitDeps.where((dep) => userDefinedGroup.nameRegexp.hasMatch(dep.name)));
        deps.addAll(pathDeps.where((dep) => userDefinedGroup.nameRegexp.hasMatch(dep.name)));
        if (deps.isNotEmpty) {
          userDefinedGroupsDeps[userDefinedGroup.title] = deps;
        }
      }
    }

    final reportContent = ReportContent(
      title: title,
      projectName: projectName,
      projectVersion: projectVersion,
      totalNumberDependencies: totalNumberDependencies,
      sdks: sdks,
      directDeps: directDeps,
      devDeps: devDeps,
      transitiveDeps: transitiveDeps,
      gitDeps: gitDeps,
      pathDeps: pathDeps,
      userDefinedGroupsDeps: userDefinedGroupsDeps,
    );

    if (generatePdf) {
      await PDFGenerator.createExport(
        content: reportContent,
        outputFilepath: _constructFilepath(outputDirectory, outputFilename, FileType.pdf),
      );
    }

    if (generateMd) {
      await MDGenerator.createExport(
        content: reportContent,
        outputFilepath: _constructFilepath(outputDirectory, outputFilename, FileType.md),
      );
    }
  }

  static String _constructFilepath(String directory, String filename, FileType fileType) {
    const _mapFileTypeExtension = {
      FileType.pdf: 'pdf',
      FileType.md: 'md',
    };
    final spacer = directory.isEmpty ? '' : directory.endsWith('/') ? '' : '/';

    return '$directory$spacer$filename.${_mapFileTypeExtension[fileType]}';
  }

  static final _scraper = PubDevScraper();

  static Future<List<Dependency>> _fromPubDev(
    List<PackageDependency> packages, {
    ReportDependencyType type,
  }) async {
    final deps = <Dependency>[];
    for (final package in packages) {
      final dep = package.isSDK
          ? Dependency(name: package.package(), about: 'Part of SDK')
          : await () async {
              final scrapedData = await _scraper.forPackage(package.package());
              return Dependency(
                name: package.package(),
                version: package.version(),
                type: package.type(),
                reportType: type,
                score: scrapedData?.score,
                about: scrapedData?.about,
                license: scrapedData?.license,
                url: package.url,
              );
            }();
      if (dep != null) {
        deps.add(dep);
      }
    }

    return deps;
  }
}
