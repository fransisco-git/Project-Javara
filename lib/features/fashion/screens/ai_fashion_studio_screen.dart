import 'package:flutter/material.dart';

import '../models/javanese_clothing_models.dart';
import '../models/realistic_fashion_model.dart';
import 'javara_studio_screen.dart';

/// Screen 08 — AI Photorealistic Fashion Studio JAVARA (Anywear-Inspired Live Studio)
///
/// Pengalaman studio fotografi busana adat fotorealistis bertenaga AI (FASHN AI Virtual Try-On).
/// Memadukan penampil kamera ponsel langsung (Live Camera), unggahan foto peraga (Photo Mode),
/// serta model manusia fotorealistis (AI Model Mode) dengan interaksi lemari busana drag-and-drop.
class AiFashionStudioScreen extends StatelessWidget {
  const AiFashionStudioScreen({
    super.key,
    this.initialModel,
    this.initialGarment,
  });

  final RealisticFashionModel? initialModel;
  final ClothingItem? initialGarment;

  @override
  Widget build(BuildContext context) {
    return JavaraStudioScreen(
      initialModel: initialModel,
      initialGarment: initialGarment,
    );
  }
}
