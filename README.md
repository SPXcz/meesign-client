# MeeSign Client

An open-source tool for multi-party document signing, client for [MeeSign Server](https://github.com/crocs-muni/meesign-server).

To learn more about MeeSign, visit [our website](https://meesign.crocs.fi.muni.cz/).

## Build

1. [Install Flutter](https://flutter.dev/docs/get-started/install), be sure to also follow the instructions for the platform you want to build for, i.e. **enable desktop support or set up Android SDK** (all described on the same page). At the moment, the following targets are supported: **Linux, Windows, Android**

2. [Install Rust](https://www.rust-lang.org/tools/install)
   1. Android only:
      1. Add Android targets for cross-compilation

         ```bash
         rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android
         ```

      2. Point cargo to the linker provided by Android NDK, a helper script for generating the necessary configuration is provided in [tool/cargo-config-gen-android.sh](tool/cargo-config-gen-android.sh), append the output to your [cargo configuration file](https://doc.rust-lang.org/cargo/reference/config.html#hierarchical-structure), e.g. by:

         ```bash
         ANDROID_NDK_HOME="path/to/ndk/version" ANDROID_API="30" bash ./tool/cargo-config-gen-android.sh >> ~/.cargo/config.toml
         ```

3. Clone the repository:

   ```bash
   git clone https://github.com/crocs-muni/meesign-client --recurse-submodules
   ```

4. Copy MeeSign CA certificate to `assets/ca-cert.pem`

   If you have a local build of MeeSign server, the corresponding file is placed in `keys/meesign-ca-cert.pem`.

5. Build the app:

   ```bash
   flutter build
   ```

   or run it directly:

   ```bash
   flutter run
   ```

### Options

The build can be customized by passing `--dart-define=OPTION=VALUE` to `flutter run` or `flutter build`, see `flutter run --help` for more details. The following definitions are considered:

* `ALLOW_BAD_CERTS`: If `true`, certificate checks are skipped and any server certificate is accepted.

## Card Support

For increased security, the app can optionally transfer the user's private key share in the given group to a smart card. To use this feature, install a supported applet on your card and select the appropriate protocol when creating a new group.

Supported applets:

* [JCFROST](https://github.com/crocs-muni/JCFROST)
