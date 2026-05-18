import Flutter
import Photos
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let mediaSaverChannel = "mochi/media_saver"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: mediaSaverChannel,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { call, result in
        guard call.method == "saveImageToGallery" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard
          let arguments = call.arguments as? [String: Any],
          let typedData = arguments["bytes"] as? FlutterStandardTypedData,
          let image = UIImage(data: typedData.data)
        else {
          result(
            FlutterError(
              code: "INVALID_IMAGE",
              message: "Image bytes are invalid",
              details: nil
            )
          )
          return
        }

        PHPhotoLibrary.shared().performChanges({
          PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
          DispatchQueue.main.async {
            if success {
              result("saved")
            } else {
              result(
                FlutterError(
                  code: "SAVE_IMAGE_FAILED",
                  message: error?.localizedDescription ?? "Cannot save image",
                  details: nil
                )
              )
            }
          }
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
