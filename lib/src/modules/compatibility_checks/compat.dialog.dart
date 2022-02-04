import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:i18next/i18next.dart';
import 'package:sidekick/src/components/atoms/typography.dart';
import 'package:sidekick/src/modules/common/utils/notify.dart';
import 'package:sidekick/src/modules/compatibility_checks/compat.dto.dart';
import 'package:sidekick/src/modules/compatibility_checks/compat.provider.dart';

import 'compat.utils.dart';

class CompatDialog extends HookWidget {
  const CompatDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final check = useProvider(compatProvider);
    final command = _genCommand(check);

    return AlertDialog(
      title: Column(
        children: [
          Heading(I18Next.of(context)
              .t('modules:compatibility.dialog.dialogTitle')),
          const SizedBox(
            width: 15,
          ),
          Subheading(I18Next.of(context).t(Platform.isWindows
              ? 'modules:compatibility.dialog.dialogDescriptionWindows'
              : 'modules:compatibility.dialog.dialogDescriptionMacLinux'))
        ],
      ),
      content: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SelectableText(
                  command,
                  //maxLines: 1,
                  //textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                  splashRadius: 2,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: command),
                    );
                    notify(I18Next.of(context)
                        .t('components:atoms.copiedToClipboard'));
                  },
                  icon: const Icon(
                    Icons.copy,
                    size: 15,
                  ))
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(I18Next.of(context).t('modules:fvm.dialogs.cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            notify(I18Next.of(context)
                .t('modules:fvm.compatibility.dialog.dialogRestartNotication'));
            Future.delayed(const Duration(seconds: 3)).then((_) => exit(0));
          },
          child: Text(
              I18Next.of(context).t('modules:fvm.compatibility.dialog.done')),
        )
      ],
    );
  }
}

String _genCommand(CompatibilityCheck check) {
  var command = "";
  final useBrew = (Platform.isMacOS || Platform.isLinux);
  if (!check.brew && useBrew) {
    command += brewInstallCmd;
  }
  if (!check.choco && !useBrew) {
    command += chocoInstallCmd;
  }
  if (!check.git) {
    command += gitInstallCmd;
  }
  if (!check.fvm) {
    command += fvmInstallCmd;
  }
  return command;
}
