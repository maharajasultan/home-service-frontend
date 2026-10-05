import 'package:flutter/material.dart';
import 'package:reaple_app/shell/session_placeholder.dart';

class TechnicianShell extends StatelessWidget {
  const TechnicianShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const SessionPlaceholder(
      title: 'Area Teknisi',
      note: 'Sementara. Di F7 halaman ini diganti dashboard pesanan, foto, dan live location.',
    );
  }
}