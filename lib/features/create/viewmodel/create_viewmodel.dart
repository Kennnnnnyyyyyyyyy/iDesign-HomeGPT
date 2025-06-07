import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/features/create/model/auth_model.dart';

final designInputProvider =
    StateNotifierProvider<DesignInputController, CreateDesignInput?>((ref) {
      return DesignInputController();
    });

class DesignInputController extends StateNotifier<CreateDesignInput?> {
  DesignInputController() : super(null);

  void setDesignInput(CreateDesignInput input) {
    state = input;
  }

  void clear() => state = null;
}
