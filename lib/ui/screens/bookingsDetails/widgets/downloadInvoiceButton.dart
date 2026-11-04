import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadInvoiceButton extends StatelessWidget {
  final String bookingId;
  final String buttonScreenName;
  final bool compact;
  final bool large;

  const DownloadInvoiceButton({
    super.key,
    required this.bookingId,
    required this.buttonScreenName,
    this.compact = false,
    this.large = false,
  });

  static Future<bool> checkStoragePermission() async {
    if (Platform.isIOS) {
      var permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        return permissionGiven = (await Permission.storage.request()).isGranted;
      }
      return permissionGiven;
    }
    //if it is for android
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    if (androidDeviceInfo.version.sdkInt < 33) {
      var permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        return permissionGiven = (await Permission.storage.request()).isGranted;
      }
      return permissionGiven;
    } else {
      var permissionGiven = await Permission.photos.isGranted;
      if (!permissionGiven) {
        return permissionGiven = (await Permission.photos.request()).isGranted;
      }
      return permissionGiven;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DownloadInvoiceCubit, DownloadInvoiceState>(
      listener: (final BuildContext context, DownloadInvoiceState state) async {
        if (state is DownloadInvoiceSuccess) {
          if (state.bookingId == bookingId &&
              buttonScreenName == state.buttonScreenName) {
            try {
              final bool checkPermission = await checkStoragePermission();
              final appDocDirPath = Platform.isAndroid && checkPermission
                  ? (await ExternalPath.getExternalStoragePublicDirectory(
                      ExternalPath.DIRECTORY_DOWNLOAD,
                    ))
                  : (await getApplicationDocumentsDirectory()).path;
              if (!context.mounted) return;

              final targetFileName =
                  "$appName-${"invoice".translate(context: context)}-$bookingId.pdf";

              final File file = File("$appDocDirPath/$targetFileName");

              // Write down the file as bytes from the bytes got from the HTTP request.
              await file.writeAsBytes(state.invoiceData).then((final value) {
                if (!context.mounted) return;
                UiUtils.showMessage(
                  context,
                  'invoiceDownloadedSuccessfully'.translate(context: context),
                  ToastificationType.success,
                );

                OpenFile.open(file.path);
              });
            } catch (e) {
              if (!context.mounted) return;
              UiUtils.showMessage(
                context,
                'somethingWentWrong'.translate(context: context),
                ToastificationType.error,
              );
            }
          }
        } else if (state is DownloadInvoiceFailure) {
          if (state.bookingId == bookingId)
            UiUtils.showMessage(
              context,
              state.errorMessage,
              ToastificationType.error,
            );
        }
      },
      builder: (final BuildContext context, final DownloadInvoiceState state) {
        Widget? child;
        if (state is DownloadInvoiceInProgress) {
          if (state.bookingId == bookingId &&
              buttonScreenName == state.buttonScreenName)
            child = CustomCircularProgressIndicator(
              color: context.colors.iconBrand,
            );
        }

        final VoidCallback onTap = () {
          context.read<DownloadInvoiceCubit>().downloadInvoice(
            bookingId: bookingId,
            buttonScreenName: buttonScreenName,
          );
        };

        if (large) {
          return CustomInkWellContainer(
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
            onTap: onTap,
            child: CustomContainer(
              padding: const EdgeInsets.all(12),
              color: context.colors.backgroundBrandSubtle,
              border: Border.all(color: context.colors.borderBrand),
              borderRadius: UiUtils.borderRadiusOf12,
              alignment: Alignment.center,
              child: child != null
                  ? CustomCircularProgressIndicator(
                      color: context.colors.iconBrand,
                    )
                  : CustomText(
                      'getInvoice'.translate(context: context),
                      maxLines: 1,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textBrand,
                    ),
            ),
          );
        }

        if (compact) {
          return CustomInkWellContainer(
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
            onTap: onTap,
            child: CustomContainer(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              color: context.colors.backgroundBrandSubtle,
              border: Border.all(color: context.colors.borderBrand),
              borderRadius: UiUtils.borderRadiusOf8,
              alignment: Alignment.center,
              child: child != null
                  ? CustomCircularProgressIndicator(
                      color: context.colors.iconBrand,
                      widthAndHeight: 20,
                    )
                  : CustomText(
                      'getInvoice'.translate(context: context),
                      maxLines: 1,
                      fontSize: 14,
                      color: context.colors.textBrand,
                    ),
            ),
          );
        }

        return Align(
          alignment: Alignment.bottomCenter,
          child: CustomRoundedButton(
            onTap: onTap,
            backgroundColor: context.colors.backgroundBrandSubtle,
            radius: UiUtils.borderRadiusOf5,
            buttonTitle: '',
            showBorder: false,
            widthPercentage: 0.9,
            titleColor: context.colors.textBrand,
            shadowColor: context.colors.backgroundBrandSubtle,
            child:
                child ??
                CustomText(
                  "getInvoice".translate(context: context),
                  maxLines: 1,
                  color: context.colors.textBrand,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
        );
      },
    );
  }
}
