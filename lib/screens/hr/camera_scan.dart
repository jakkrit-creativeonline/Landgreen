import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:system/configs/constants.dart';
import 'package:system/services/hr_services.dart';

class CameraScan extends StatefulWidget {
  @override
  _CameraScanState createState() => _CameraScanState();
}

class _CameraScanState extends State<CameraScan> {
  FormatMethod f = new FormatMethod();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;

  // var currenttime = DateFormat("dd-MM-yyyy HH:mm").format(DateTime.now());

  // @override
  // void initState() {
  //   Future.delayed(Duration.zero, () async {
  //     SharedPrefs().saveValue('currenttime',currenttime.toString());
  //     SharedPrefs().getValue('currenttime');
  //   });
  //   super.initState();
  // }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      Future.delayed(Duration.zero, () async {
        var now = DateTime.now();
        var saveformat = f.DateTimeFormat(now);
        HrServices().setValue('currentCheckin',saveformat.toString());
        HrServices().setValue('locationCheckin',result.code);
        Navigator.of(context).pop(result.code);
      });
    }

    return Scaffold(
      body: Center(
        child: _buildQrView(context),
      ),
    );
  }
  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        controller.pauseCamera();
      });
    });
  }
  @override
  void dispose() {
    controller?.dispose();
    // print('วัน เวลา => ${currenttime}');
    print('ssssss dispose => ${result.code}');

    super.dispose();
  }

}
