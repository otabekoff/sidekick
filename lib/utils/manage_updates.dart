import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sidekick/constants.dart';
import 'package:sidekick/utils/open_link.dart';

final platform = Platform.operatingSystem;

const downloadBaseUrl = "$kGithubSidekickUrl/releases/download";

String getDownloadReleaseUrl(String release) {
  return "$downloadBaseUrl/$release/Sidekick-$platform-$release.$platformExt";
}

Future<File> getFileLocation(String release) async {
  final downloadDir = await getDownloadsDirectory();
  final filePath =
      path.join(downloadDir.absolute.path, "sidekick-$release.$platformExt");
  return File(filePath);
}

Future<void> downloadRelease(String release) async {
  final downloadUrl = getDownloadReleaseUrl(release);
  final file = await getFileLocation(release);

  if (!await file.exists()) {
    showToast("Downloading...", duration: const Duration(seconds: 30));
    var res = await http.get(downloadUrl);
    if (res.statusCode == 200) {
      await file.writeAsBytes(res.bodyBytes);
      showToast("Release downloaded! Opening...", dismissOtherToast: true);
    } else {
      showToast(
        "There was an issue downloading the file, plese try again later."
        "\nCode ${res.statusCode}",
        dismissOtherToast: true,
      );
      return;
    }
  } else {
    showToast("File already downloaded, opening...");
  }
  openInstaller(file);
}

Future<void> openInstaller(File file) async {
  openLink("file://${file.absolute.path.replaceAll("\\", "/")}");
}

String get platformExt {
  switch (platform) {
    case 'windows':
      {
        return 'msix';
      }
      break;
    case 'macos':
      {
        return 'dmg';
      }
      break;

    default:
      {
        return 'zip';
      }
      break;
  }
}
