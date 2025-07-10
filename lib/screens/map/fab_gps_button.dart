import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'map_controller.dart';

class FabGpsButton extends StatelessWidget {
  const FabGpsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 18,
      right: 18,
      child: FloatingActionButton.small(
        heroTag: 'userLocation',
        backgroundColor: Colors.black54,
        onPressed: () =>
            context.read<MapControllerState>().centerToUserLocation(),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
